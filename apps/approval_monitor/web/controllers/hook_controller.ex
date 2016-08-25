defmodule ApprovalMonitor.HookController do
  use ApprovalMonitor.Web, :controller
  alias ApprovalMonitor.PullRequests.{Registry,PullRequest}

  def post(%Plug.Conn{req_headers: req_headers} = conn, params) do
    with {"x-github-event", event} <- List.keyfind(req_headers, "x-github-event", 0) do
      handle_event(event, conn, params)
    else
      _ ->
        text(conn, "no event found")
    end
  end

  defp handle_event("pull_request", conn, %{"action" => action, "pull_request" => pull_request}) do
    pid =
      pull_request
      |> Map.get("id")
      |> Registry.find
    
    case pid do
      nil -> Registry.attach(pull_request)
      _ -> PullRequest.handle_action(pid, {action, pull_request})
    end
    
    text(conn, "ok")
  end

  defp handle_event(event, conn, _params) do
    text(conn, "No handler is configured for " <> event)
  end

end
