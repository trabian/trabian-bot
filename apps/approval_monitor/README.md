# ApprovalMonitor

Trabian's PR approval process is fairly straightforward:

  * Changes are submitted via PR. The submitting developer chooses one
    or more other developers to review and assigns them to the PR.
  * Assignees review code and add an "approval" reaction (the `+1`) to
    the first comment once approved (this may require a few rounds of
    comments and new commits to the PR). A "disapproval" (`-1`) will
    block the approval until removed.
  * After all assignees have approved the PR, the PR's
    [status](https://developer.github.com/v3/repos/statuses/) is
    updated to reflect the approval and is reassigned to the
    submitter, who's then responsible for merging it.

This approval monitor is responsible for updating the PR status and
reassigning. The status is checked on any of the following events:

  * An assignee(s) is added or removed. *Note: this happens when a PR
    is originally opened if an assignee is included initially.*
  * The reactions to the PR are updated.

While the assignee changes can be monitored via a webhook, the
reactions can currently only be monitored via a long poll.

When the application is started it loads all of the open PRs to which
the bot's GitHub user (@trabian-bot) has access. The status of each PR
is verified and updated if needed, then a `ReactionMonitor` is set up
for each PR.
