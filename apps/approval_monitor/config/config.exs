# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :approval_monitor, ApprovalMonitor.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UC8a4hLpaBn07h639NFtwJbNowvPvpYyh0F8mzGm/O3LO/80AzhVxxs0fnrIRNTD",
  render_errors: [view: ApprovalMonitor.ErrorView, accepts: ~w(json)],
  pubsub: [name: ApprovalMonitor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :approval_monitor, ApprovalMonitor.PullRequests.ReactionPoller,
  poll_interval: 3_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
