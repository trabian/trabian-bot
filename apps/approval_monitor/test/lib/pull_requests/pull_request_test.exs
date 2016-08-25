defmodule ApprovalMonitor.PullRequests.PullRequestTest do
  use ApprovalMonitor.GitHubCase
  alias ApprovalMonitor.PullRequests.PullRequest

  test "closing a pull request should kill its process", %{bypass: bypass, root_url: root_url} do

    Bypass.expect(bypass, &handle_request(&1))

    pr = %{
      "id" => "1",
      "url" => "#{root_url}/pulls/1",
      "assignees" => [],
      "issue_url" => "#{root_url}/issues/1",
      "state" => "open",
    }

    assert {:ok, pid} = PullRequest.start_link(pr)

    :timer.sleep(100) # Allow request to arrive at bypass

    ref = Process.monitor(pid)

    PullRequest.handle_action(pid, {"closed", pr})

    assert_receive {:DOWN, ^ref, :process, _pid, _reason}

  end

  # Ignore requests for now, but prevent calls to GitHub API
  defp handle_request(conn) do
    Plug.Conn.resp(conn, 200, Poison.encode!([]))
  end

end
