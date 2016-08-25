defmodule ApprovalMonitor.GitHubCase do
  @moduledoc """
  This module sets up a bypass for GitHub.
  """

  use ExUnit.CaseTemplate

  setup do

    bypass = Bypass.open
      
    endpoint = Application.get_env(:git_hub, :endpoint)

    root_url = endpoint_url(bypass.port)
      
    Application.put_env(:git_hub, :endpoint, root_url)
      
    on_exit fn ->
      Application.put_env(:git_hub, :endpoint, endpoint)
      :ok
    end
    
    {:ok, bypass: bypass, root_url: root_url}

  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

end

