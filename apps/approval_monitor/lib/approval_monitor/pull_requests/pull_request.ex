defmodule ApprovalMonitor.PullRequests.PullRequest do
  alias ApprovalMonitor.PullRequests.{ApprovalStatus,Registry,ReactionPoller}
  
  @moduledoc """
  Each PullRequest process is responsible for responding to (and
  polling for) events related to itself, then posting updates to the
  GitHub API as needed.

  The process should retain as little state as needed - GitHub is the
  source of truth. When possible, external events (including
  initialization) should pass as much state as needed in order to
  determine the next step without requiring an additional API call.
  However, we'll prefer re-fetching to storage.
  """

  # Client API

  def start_link(pr) do
    GenServer.start_link(__MODULE__, pr)
  end

  def check(pid) do
    GenServer.cast(pid, :check)
  end

  def handle_action(pid, {action, pull_request}) do
    GenServer.cast(pid, {:action, action, pull_request})
  end

  # Callbacks

  @doc """
  On initialization, register the PR and check to see whether the
  approval status needs to be changed. The PR map passed in
  initialization may contain more state than we want to store but we
  can pass it to the status update handlers.
  """
  def init(%{"id" => id, "url" => url} = pull_request) do

    Registry.register(id, self())
    Process.send(self(), {:check_status, pull_request}, [])

    poll_reactions(pull_request)
    
    {:ok, %{id: id, url: url}}
    
  end

  def handle_cast({:action, action, pull_request}, state) when action in ["assigned", "unassigned"] do
    check_approval_status(state, pull_request)
    {:noreply, state}
  end

  def handle_cast({:action, _, _}, state) do
    {:noreply, state}
  end

  def handle_cast(:check, state) do
    check_approval_status(state, nil)
    {:noreply, state}
  end

  def handle_info({:check_status, pull_request}, state) do
    check_approval_status(state, pull_request)
    {:noreply, state}
  end

  def handle_info({:update_reactions, reactions}, state) do
    check_approval_status(state, %{"reactions" => reactions})
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state) do

  end

  @doc """
  A PR is approved if the assignees have given a "thumbs up" reaction
  to it. To check status, we'll need the following for a PR:

    * The current assignees
    * The current reactions

  If these are missing from the pull_request map then we'll load them.
  """
  def check_approval_status(%{url: url}, pr_map) do

    with {:ok, pull_request} <- get_pull_request(url, pr_map),
         {:ok, reactions} <- get_reactions(pull_request),
           status_url <- Map.get(pull_request, "statuses_url"),
           assignees <- Map.get(pull_request, "assignees") do

      status =
        assignees
        |> ApprovalStatus.status(reactions)
        |> Map.put(:context, "trabian/code-review")
        |> Poison.encode!()
      
      GitHub.post(status_url, status)
      
    end

  end

  defp poll_reactions(pull_request) do
    pull_request
    |> reaction_url()
    |> ReactionPoller.start_link(self())
  end

  defp reaction_url(pull_request) do
    Map.get(pull_request, "issue_url") <> "/reactions"
  end
  
  # We'll use the presence of the state attribute to signal that we have
  # the PR map.
  defp get_pull_request(_, %{"state" => _} = pull_request), do: {:ok, pull_request}

  defp get_pull_request(url, pr_map) do
    pull_request =
      url
      |> GitHub.PullRequest.get
      |> Map.merge(pr_map)
    {:ok, pull_request}
  end

  defp get_reactions(%{"reactions" => reactions}), do: {:ok, reactions}
  
  defp get_reactions(%{"issue_url" => issue_url}) do
    reactions_url = issue_url <> "/reactions"
    
    reactions =
      reactions_url
      |> GitHub.PullRequest.get
    
    {:ok, reactions}
  end

  # defp update_approval_status(%{"statuses_url" => statuses_url} = pull_request) do

  #   body =
  #     pull_request
  #     |> IO.inspect
  #     |> pending_approvals
  #     |> approval_status
  #     |> Map.put(:context, "trabian/code-review")

  #   # GitHub.post(statuses_url, body)
    
  # end

  # defp update_approval_status(%{"url" => url}) do

  #   url
  #   |> GitHub.PullRequest.get
  #   |> update_approval_status
    
  # end

end
