import * as R from "ramda";

import { gql } from "./utils";

const fileContentsQuery = gql`
  query getFile($expression: String!, $owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      object(expression: $expression) {
        ... on Blob {
          text
        }
      }
    }
  }
`;

const getFileExpression = ({ branch, path }) => [branch, path].join(":");

export const getFileContents = (context, { owner, repo, branch, path }) =>
  context.github
    .query(fileContentsQuery, {
      owner,
      repo,
      expression: getFileExpression({
        branch,
        path,
      }),
    })
    .then(R.path(["repository", "object", "text"]));
