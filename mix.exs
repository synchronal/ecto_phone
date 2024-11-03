defmodule EctoPhone.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_phone,
      deps: deps(),
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application,
    do: [
      extra_applications: [:logger]
    ]

  defp deps, do: []
end
