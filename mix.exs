defmodule EctoPhone.MixProject do
  use Mix.Project

  @homepage "https://github.com/synchronal/ecto_phone"
  @version "1.0.0"

  def project do
    [
      app: :ecto_phone,
      deps: deps(),
      description: "An Ecto.ParameterizedType for phone numbers",
      dialyzer: dialyzer(),
      elixir: "~> 1.17",
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

  defp deps,
    do: [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_sql, "> 0.0.0", optional: true},
      {:ecto, "~> 3.12"},
      {:ecto_temp, "~> 1.1", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev], runtime: false},
      {:postgrex, "> 0.0.0", optional: true}
    ]

  defp dialyzer,
    do: [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_core_path: "_build/plts/#{Mix.env()}",
      plt_local_path: "_build/plts/#{Mix.env()}"
    ]

  defp package,
    do: [
      files: ~w(lib .formatter.exs mix.exs *.md),
      licenses: ["MIT"],
      maintainers: ["synchronal.dev", "Erik Hanson", "Eric Saxby"],
      links: %{"GitHub" => @homepage}
    ]
end
