defmodule GitHub.PullRequest do

  def get(url) do
    GitHub.get_body(url)
  end

  @doc """
  Load the user's repos and look for any that have open issues, then load
  the open pull requests from those PRs in parallel. The seems to be the
  only way to load all PRs across all a user's repositories (we tried
  leveraging the Search API). The main downside is the API's request
  throttling.
  """
  def list_my_open_prs() do
    prs =
      GitHub.get_body("/user/repos")
      |> Enum.filter(&has_issues?/1)
      |> Enum.map(&list_open_prs/1)
      |> Enum.flat_map(&Task.await/1)
    {:ok, prs}
  end

  defp list_open_prs(%{"url" => url}) do
    Task.async fn ->
      GitHub.get_body("#{url}/pulls?status=open")
    end
  end

  defp has_issues?(%{"open_issues_count" => count}) do
    count > 0
  end

end
