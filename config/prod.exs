use Mix.Config

config :collabex_web, CollabexWeb.Endpoint,
  server: true,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: false

config :logger,
  level: :info,
  format: "$dateT$time [$level] $levelpad$metadata- $message\n",
  metadata: [:request_id, :module]
