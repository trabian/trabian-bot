defmodule ApprovalMonitor.PullRequests.Loader do
  @moduledoc """
  The Pull Request Loader is responsible for loading existing PRs from
  the GitHub API, both on startup (asynchronously to prevent blocking
  of the startup process) and when asked to `reload`.
  """
  
  use GenServer
  alias GitHub.PullRequest

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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

  @doc """
  Refresh the list of PRs from the API.
  """
  def reload do
    GenServer.cast(__MODULE__, :reload)
  end

  @doc """
  Each pull request will spawn a separate process to respond to
  (and poll for) events related to that PR, then post updates to
  the GitHub API as needed.
  """
  def handle_info(:load, state) do
    load_pulls()
    {:noreply, state}
  end

  def handle_cast(:reload, state) do
    load_pulls()
    {:noreply, state}
  end

  defp load_pulls() do
    {:ok, pulls} = PullRequest.list_my_open_prs()
    Enum.each(pulls, &ApprovalMonitor.PullRequests.Registry.attach/1)
  end

end
