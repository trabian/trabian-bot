defmodule ApprovalMonitor.PullRequests.Supervisor do
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

  def attach(pull_request) do
    Supervisor.start_child(__MODULE__, [pull_request])
  end

end
