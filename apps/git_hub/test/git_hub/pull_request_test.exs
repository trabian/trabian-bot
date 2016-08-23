defmodule GitHub.PullRequestTest do
  use ExUnit.Case
  doctest GitHub
  alias GitHub.PullRequest

  setup do
    bypass = Bypass.open
      
    endpoint = Application.get_env(:git_hub, :endpoint)
      
    Application.put_env(:git_hub, :endpoint, endpoint_url(bypass.port))
      
    on_exit fn ->
      Application.put_env(:git_hub, :endpoint, endpoint)
      :ok
    end
    
    {:ok, bypass: bypass}
  end

  test "list_my_open_prs when no repos are returned", %{bypass: bypass} do

    Bypass.expect bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "{}")
    end

    {:ok, prs} = PullRequest.list_my_open_prs

    assert prs == []
    
  end

  test "list_my_open_prs when a repo is returned", %{bypass: bypass} do

    prs =
      Enum.to_list(0..10)
      |> Enum.map(&(%{"id" => &1}))

    Bypass.expect bypass, fn conn ->

      case conn.request_path do
        "/user/repos" ->
          body = [%{"open_issues_count" => 1,
                    "url" => "/repo"}]
          
          Plug.Conn.resp(conn, 200, Poison.encode!(body))
          
        "/repo/pulls" ->
          body = prs
          Plug.Conn.resp(conn, 200, Poison.encode!(body))
      end
      
    end

    {:ok, resp} = PullRequest.list_my_open_prs

    assert resp == prs
    
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

end
