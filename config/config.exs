# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config



config :collabex_web,
  generators: [context_app: :collabex]

# Configures the endpoint
config :collabex_web, CollabexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ywLMX08lI5WywxYFg7vmXzWBMRVmVwTa9fXq/97PR7TZY3yEYDIElh8ZgNJwRWNO",
  render_errors: [view: CollabexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Collabex.PubSub,
  live_view: [signing_salt: "ErLM4qVk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
