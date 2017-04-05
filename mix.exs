defmodule Podcatcher.Mixfile do
  use Mix.Project

  def project do
    [app: :podcatcher,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Podcatcher.Application, []},
     extra_applications: [:logger, :runtime_tools, :scrivener_ecto]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:mock, "~> 0.2.0", only: :test},
     {:gettext, "~> 0.11"},
     {:arc, "~> 0.7.0"},
     {:arc_ecto, "~> 0.6.0"},
     {:httpoison, "~> 0.11.1"},
     {:sweet_xml, "~> 0.6.5"},
     {:ecto_autoslug_field, "~> 0.2"},
     {:timex, "~> 3.0"},
     {:earmark, "~> 1.2.0"},
     {:html_sanitize_ex, "~> 1.0.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:poolboy, "~> 1.5"},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
