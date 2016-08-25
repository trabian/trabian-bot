defmodule ApprovalMonitor.PullRequests do
  @moduledoc """
  Supervision tree for pull requests. The order specified in the
  `children` list represents the dependency order of the processes
  (a characteristic of OTP supervisors).
  """
  
  use Supervisor
  alias ApprovalMonitor.PullRequests.{Loader, Registry}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ApprovalMonitor.PullRequests.Supervisor, []),
      worker(Registry, []),
      worker(Loader, []),
    ]

    supervise(children, strategy: :one_for_all)
  end

end
