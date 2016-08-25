defmodule ApprovalMonitor.PullRequests.ReactionPoller do
  @moduledoc """
  The ReactionPoller is responsible for polling the GitHub "Reactions"
  API at a predefined interval (the `poll_interval` config variable
  scoped to this module). If the reaction has changed from the
  previous poll, an `{:update_reactions, body}` message is sent to the
  `from` process specified during linking.
  """
  
  use GenServer

  @poll_interval Application.get_env(:approval_monitor, __MODULE__)[:poll_interval]

  def start_link(url, from) do
    GenServer.start_link(__MODULE__, [url, from])
  end

  def init([url, from]) do
    Process.send_after(self(), :poll, @poll_interval)
    {:ok, %{url: url, from: from, previous: nil}}
  end

  # Callbacks

  def handle_info(:poll, state) do

    case GitHub.get(state.url) do
      {:ok, %{body: body}} ->
        Process.send_after(self(), :poll, @poll_interval)
        if body != state.previous do
          Process.send(state.from, {:update_reactions, body}, [])
          {:noreply, Map.put(state, :previous, body)}
        else
          {:noreply, state}
        end
    end

  end

end
