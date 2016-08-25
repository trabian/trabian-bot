defmodule ApprovalMonitor.PullRequests.ApprovalStatus do
  @moduledoc """
  GitHub uses
  [statuses](https://developer.github.com/v3/repos/statuses/) for
  displaying whether a commit (or PR) can be merged. This module
  creates the status payload based on the approval status of the PR.
  """

  @doc """
  Get the current status of the pull request based on the assignees
  and reactions.
  """
  def status(assignees, reactions) do
    get_approvals(assignees, reactions)
    |> message
  end

  defp get_approvals(assignee_maps, reactions) do

    assignees =
      assignee_maps
      |> Enum.map(&(Map.get(&1, "login")))

    approvals =
      reactions
      |> Enum.filter(&approval_reaction?/1)
      |> Enum.map(&get_login/1)

    %{
      remaining: assignees -- approvals,
      assignees: assignees,
    }

  end

  defp message(%{remaining: [], assignees: assignees}) do
    description =
      case assignees do
        [] -> "No approval required"
        _ -> "All assignees have approved this pull request."
      end

    %{
      state: "success",
      description: description
    }
  end

  defp message(%{remaining: remaining}) do
    names = Enum.join(remaining, ", ")

    %{
      state: "pending",
      description: "Waiting for approval from " <> names
    }
  end

  defp approval_reaction?(%{"content" => content}) do
    content in ["+1"]
  end

  defp get_login(user) do
    get_in(user, ["user", "login"])
  end

end
