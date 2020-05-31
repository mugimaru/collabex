defmodule Collabex.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [check: :test],
      aliases: aliases(),
      releases: [
        collabex: [
          include_executables_for: [:unix],
          applications: [
            runtime_tools: :permanent,
            collabex: :permanent,
            collabex_web: :permanent
          ]
        ]
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"],
      check: ["compile --force --warnings-as-errors", "test", "credo", "dialyzer"]
    ]
  end
end
