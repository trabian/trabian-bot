defmodule ApprovalMonitor.PullRequests.LoaderTest do
  use ApprovalMonitor.GitHubCase
  
  test "starting the loader should load and watch the PRs", %{bypass: bypass, root_url: root_url} do

    # Bypass currently doesn't support concurrent requests:
    # https://github.com/PSPDFKit-labs/bypass/issues/12
    count = 1

    pulls =
      1..count
      |> Enum.to_list()
      |> Enum.map(&(fake_pull(&1, root_url)))

    Bypass.expect(bypass, &handle_request(&1, pulls))
    
    {:ok, _} = ApprovalMonitor.PullRequests.start_link

    :timer.sleep(100)

    assert Supervisor.count_children(ApprovalMonitor.PullRequests.Supervisor).active == count

  end

  defp fake_pull(id, root_url) do
    %{
      "id" => Integer.to_string(id),
      "url" => "#{root_url}/repos/1/pulls/#{id}",
      "issue_url" => "#{root_url}/repos/1/issues/#{id}"
    }
  end

  # Request handlers

  defp handle_request(%{request_path: "/user/repos"} = conn, _pulls) do
    repos = [%{"id" => 1,
               "open_issues_count" => 1,
               "url" => "/repos/1"}]
    
    Plug.Conn.resp(conn, 200, Poison.encode!(repos))
  end
  
  defp handle_request(%{request_path: "/repos/1/pulls"} = conn, pulls) do
    Plug.Conn.resp(conn, 200, Poison.encode!(pulls))
  end
  
  defp handle_request(%{request_path: "/issue/reactions"} = conn, _pulls) do
    reactions = [%{"content" => "+1",
                   "user" => %{
                     "login" => "test1",
                   }}]
    
    Plug.Conn.resp(conn, 200, Poison.encode!(reactions))
  end

  defp handle_request(%{request_path: "/repos/1/pulls/" <> id} = conn, pulls) do

    pull = Enum.find(pulls, &(Map.get(&1, "id") == id))

    pull = Map.merge(pull,
      %{
        "statuses_url" => "/statuses",
        "issue_url" => "/issue",
        "assignees" => [
          %{"login" => "user1"}
        ]
      })

    Plug.Conn.resp(conn, 200, Poison.encode!(pull))
  end

  defp handle_request(conn, _pulls) do
    Plug.Conn.resp(conn, 200, "[]")
  end

end
