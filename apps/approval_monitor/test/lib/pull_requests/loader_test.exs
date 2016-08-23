defmodule ApprovalMonitor.PullRequests.LoaderTest do
  use ApprovalMonitor.GitHubCase, async: true
  
  test "starting the loader should load and watch the PRs", %{bypass: bypass} do

    count = 10

    pulls =
      Enum.to_list(0..count)
      |> Enum.map(&(%{"id" => &1}))

    Bypass.expect bypass, fn conn ->

      case conn.request_path do
        "/user/repos" ->
          repos = [%{"id" => 1,
                    "open_issues_count" => 1,
                    "url" => "/repos/1"}]
          
          Plug.Conn.resp(conn, 200, Poison.encode!(repos))
          
        "/repos/1/pulls" ->
          Plug.Conn.resp(conn, 200, Poison.encode!(pulls))
      end
      
    end
    
    {:ok, _} = ApprovalMonitor.PullRequests.start_link

    :timer.sleep(100)

    # assert Supervisor.count_children(ApprovalMonitor.PullRequests.Supervisor) == count

  end

end
