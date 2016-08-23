defmodule ApprovalMonitor.GitHubCase do
  @moduledoc """
  This module sets up a bypass for GitHub.
  """

  use ExUnit.CaseTemplate

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

  defp endpoint_url(port), do: "http://localhost:#{port}"

end

