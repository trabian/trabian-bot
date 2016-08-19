defmodule GitHubTest do
  use ExUnit.Case
  doctest GitHub

  setup config do
    if config[:bypass] do
      bypass = Bypass.open
      
      endpoint = Application.get_env(:git_hub, :endpoint)
      
      Application.put_env(:git_hub, :endpoint, endpoint_url(bypass.port))
      
      on_exit fn ->
        Application.put_env(:git_hub, :endpoint, endpoint)
        :ok
      end
      
      {:ok, bypass: bypass}
    else
      :ok
    end
  end

  test "process_url" do
    endpoint = Application.get_env(:git_hub, :endpoint)
    
    assert GitHub.process_url(endpoint <> "/users") == endpoint <> "/users"
    assert GitHub.process_url("/users") == endpoint <> "/users"
  end

  @tag :bypass
  test "requests add the headers from the environment", %{bypass: bypass} do

    headers = Application.get_env(:git_hub, :headers)

    Application.put_env(:git_hub, :headers, [
          {"Test", "testing"},
          {"Other_test", "other test"}
        ])

    Bypass.expect bypass, fn conn ->
      assert Plug.Conn.get_req_header(conn, "test") == ["testing"]
      assert Plug.Conn.get_req_header(conn, "other_test") == ["other test"]
      
      Plug.Conn.resp(conn, 200, "{}")
    end
    
    GitHub.get "/ping"
    
    Application.put_env(:git_hub, :headers, headers)
    
  end
  
  @tag :bypass
  test "requests add authorization headers", %{bypass: bypass} do

    token = Application.get_env(:git_hub, :access_token)

    Application.put_env(:git_hub, :access_token, "1234")

    Bypass.expect bypass, fn conn ->
      assert Plug.Conn.get_req_header(conn, "authorization") == ["token 1234"]
      Plug.Conn.resp(conn, 200, "{}")
    end
    
    GitHub.get "/ping"
    
    Application.put_env(:git_hub, :access_token, token)
    
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

end
