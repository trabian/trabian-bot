defmodule ApprovalMonitor.Router do
  use ApprovalMonitor.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApprovalMonitor do
    pipe_through :api
    get "/status", HookController, :status
    post "/hook", HookController, :post
  end
end
