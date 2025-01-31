defmodule EctoPhone.MixProject do
  use Mix.Project

  @homepage "https://github.com/synchronal/ecto_phone"
  @version "2.0.0"

  def project do
    [
      aliases: aliases(),
      app: :ecto_phone,
      deps: deps(),
      description: "An Ecto.ParameterizedType for phone numbers",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: @homepage,
      name: "EctoPhone",
      package: package(),
      source_url: @homepage,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application,
    do: [
      extra_applications: [:logger]
    ]

  def cli,
    do: [
      preferred_envs: [
        credo: :test,
        dialyzer: :test
      ]
    ]

  # # #

  defp aliases,
    do: [
      test: ["ecto.create --quiet", "test"]
    ]

  defp deps,
    do: [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.12"},
      {:ecto_sql, "> 0.0.0", only: :test},
      {:ecto_temp, "~> 2.0", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:ex_phone_number, "~> 0.4"},
      {:mix_audit, "~> 2.1", only: [:dev], runtime: false},
      {:phoenix_html, "~> 4.1", optional: true},
      {:postgrex, "> 0.0.0", only: :test},
      {:schema_assertions, "~> 2.0", only: :test}
    ]

  defp dialyzer,
    do: [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_core_path: "_build/plts/#{Mix.env()}",
      plt_local_path: "_build/plts/#{Mix.env()}"
    ]

  defp docs,
    do: [
      main: "EctoPhone",
      extras: ["LICENSE.md", "CHANGELOG.md"]
    ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package,
    do: [
      files: ~w(lib .formatter.exs mix.exs *.md),
      licenses: ["MIT"],
      maintainers: ["synchronal.dev", "Erik Hanson", "Eric Saxby"],
      links: %{"GitHub" => @homepage}
    ]
end
