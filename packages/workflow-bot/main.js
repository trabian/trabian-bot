import pullRequestHandler from "./src/pull-request-handler";

export default robot => {
  robot.on(
    ["pull_request.opened", "pull_request.reopened"],
    pullRequestHandler
  );
};
