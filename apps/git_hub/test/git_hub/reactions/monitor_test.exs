defmodule GitHub.Reactions.MonitorTest do
  use ExUnit.Case, async: true
  alias GitHub.Reactions.Monitor
  
  doctest Monitor

  test "starting the monitor should create a supervision tree with the endpoints passed" do
    {:ok, monitor} = Monitor.start_link
    assert Supervisor.count_children(monitor).workers == 0
  end
  
end
