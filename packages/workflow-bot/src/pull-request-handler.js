import * as R from "ramda";

import { getFileContents } from "./files";
import { gql } from "./utils";

const containsWIP = R.test(/\b(wip|do not merge|work in progress)\b/i);

const pullRequestQuery = gql`
  query getPullRequest($number: Int!, $owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        id
        title
        author {
          login
        }
        reviewers: reviewRequests(first: 10) {
          nodes {
            requestedReviewer {
              ... on User {
                login
              }
            }
          }
        }
      }
    }
  }
`;

const getPullRequest = (context, { owner, repo, number }) =>
  context.github
    .query(pullRequestQuery, {
      owner,
      repo,
      number,
    })
    .then(R.path(["repository", "pullRequest"]));

const requestReviewQuery = gql`
  mutation requestReviews($id: ID!, $userIds: [ID!]) {
    requestReviews(input: { pullRequestId: $id, userIds: $userIds }) {
      clientMutationId
    }
  }
`;

const workflowPath = ".trabian/workflow.json";

export default async context => {
  const {
    repository: repo,
    number,
    pull_request: { head: { ref } },
  } = context.payload;

  const config = await getFileContents(context, {
    owner: repo.owner.login,
    repo: repo.name,
    branch: ref,
    path: workflowPath,
  }).then(JSON.parse);

  const pullRequest = await getPullRequest(context, {
    owner: repo.owner.login,
    repo: repo.name,
    number,
  }).then(
    R.evolve({
      reviewers: R.pipe(
        R.prop("nodes"),
        R.map(R.path(["requestedReviewer", "login"]))
      ),
    })
  );

  if (R.isEmpty(pullRequest.reviewers) && !containsWIP(pullRequest.title)) {
    const availableDevelopers = R.pipe(
      R.path(["reviewers", "code"]),
      R.without([pullRequest.author.login])
    )(config);

    const response = await context.github.query(requestReviewQuery, {
      id: pullRequest.id,
      userIds: [availableDevelopers[0]],
    });

    console.warn("response", response);
  } else {
    console.warn("we already have a reviewer!");
  }

  context.log(pullRequest, config);
};
