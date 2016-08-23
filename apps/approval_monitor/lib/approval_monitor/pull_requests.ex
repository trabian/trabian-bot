defmodule ApprovalMonitor.PullRequests do
  use Supervisor
  alias ApprovalMonitor.PullRequests.{Loader}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ApprovalMonitor.PullRequests.Supervisor, []),
      worker(Loader, []),
    ]

    supervise(children, strategy: :one_for_all)
  end

end
