defmodule ApprovalMonitor.PullRequests.Supervisor do
  @moduledoc """
  Supervision tree responsible for monitoring each Pull Request
  process. PRs are attached (and automatically detached) via the
  `ApprovalMonitor.PullRequests.Registry`, which is dependent on this
  supervisor.
  """
  
  use Supervisor
  alias ApprovalMonitor.PullRequests.PullRequest

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(PullRequest, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
