defmodule ApprovalMonitor.PullRequests.Registry do
  @moduledoc """
  The pull request registry is responsible for maintaining references
  between pull requests and their worker processes.
  """

  use GenServer

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register(id, pid) do
    GenServer.cast(__MODULE__, {:register, id, pid})
  end

  def find(id) do
    GenServer.call(__MODULE__, {:find, id})
  end

  @doc """
  Attach the pull request to the supervisor unless it's already in the
  registry, in which case it will return `:already_attached`.
  """
  def attach(%{"id" => id} = pull_request) do
    if find(id) do
      :already_attached
    else
      Supervisor.start_child(ApprovalMonitor.PullRequests.Supervisor, [pull_request])
    end
  end

  ## Server callbacks
  def handle_call({:find, id}, _from, ids) do
    {:reply, Map.get(ids, id), ids}
  end
  
  def handle_cast({:register, id, pid}, ids) do
    if Map.has_key?(ids, id) do
      {:noreply, ids}
    else
      Process.monitor(pid)
      {:noreply, Map.put(ids, id, pid)}
    end
  end

  def handle_info({:DOWN, _, :process, pid, _}, ids) do
    {:noreply, deregister_pid(ids, pid)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp deregister_pid(ids, pid) do
    Enum.reduce(
      ids,
      ids,
      fn
        ({id, registered_pid}, acc) when registered_pid == pid ->
          Map.delete(acc, id)
        (_, acc) -> acc
      end
    )
  end

end
