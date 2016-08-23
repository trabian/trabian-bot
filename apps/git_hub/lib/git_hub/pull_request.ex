defmodule GitHub.PullRequest do
  alias Experimental.Flow

  @doc """
  Load the user's repos and look for any that have open issues, then load
  the open pull requests from those PRs in parallel. The seems to be the
  only way to load all PRs across all a user's repositories (we tried
  leveraging the Search API). The main downside is the API's request
  throttling.
  """
  def list_my_open_prs() do
    GitHub.get("/user/repos")
    |> extract_body
    |> Enum.filter(&has_issues?/1)
    |> Flow.from_enumerable()
    |> Flow.map(&list_open_prs/1)
    |> Enum.to_list()
  end

  defp list_open_prs(%{"url" => url}) do
    GitHub.get("#{url}/pulls?status=open")
    |> extract_body
  end

  defp has_issues?(%{"open_issues_count" => count}) do
    count > 0
  end

  defp extract_body({:ok, %{body: body}}) do
    body
  end

end
