defmodule ApprovalMonitor.PullRequests.Loader do
  use GenServer
  alias GitHub.PullRequest

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  On initialization we'll load the open pull requests from the
  authenticated GitHub user's repos.

  Any failure during startup of a supervisor tree will cause the
  whole tree to crash, so we respond immediately from `init` and
  asynchronously load the PRs. This server's supervisor can then
  handle any errors appropriately.
  """
  def init([]) do
    Process.send(self(), :load, [])
    {:ok, []}
  end

  def handle_info(:load, state) do
    {:ok, _pulls} = PullRequest.list_my_open_prs()

    {:noreply, state}
  end
	
end
