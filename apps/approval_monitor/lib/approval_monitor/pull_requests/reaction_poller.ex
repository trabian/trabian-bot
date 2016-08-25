defmodule ReactionPoller do
	use GenServer

  @poll_duration 3_000

  def start_link(url, from) do
    GenServer.start_link(__MODULE__, [url, from])
  end

  def init([url, from]) do
    Process.send_after(self(), :poll, @poll_duration)
    {:ok, %{url: url, from: from, previous: nil}}
  end

  # Callbacks

  def handle_info(:poll, state) do

    case GitHub.get(state.url) do
      {:ok, %{body: body}} ->
        Process.send_after(self(), :poll, @poll_duration)
        if body != state.previous do
          Process.send(state.from, {:update_reactions, body}, [])
          {:noreply, Map.put(state, :previous, body)}
        else
          {:noreply, state}
        end
      {:error, error} ->
        IO.inspect(error)
    end
    
  end

end
