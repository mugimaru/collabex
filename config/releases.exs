import Config

config :collabex_web, CollabexWeb.Endpoint,
  url: [
    host: System.get_env("COLLABEX_URL_HOST", "localhost"),
    port: System.get_env("COLLABEX_URL_PORT", "4000") |> String.to_integer()
  ],
  cache_static_manifest: "../../apps/collabex_web/priv/static/cache_manifest.json"
