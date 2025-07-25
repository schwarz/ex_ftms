defmodule ExFTMS.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Helps you decode and encode Bluetooth FTMS packets in Elixir"
  @github_url "https://github.com/schwarz/ex_ftms"

  def project do
    [
      app: :ex_ftms,
      version: @version,
      name: "ExFTMS",
      description: @description,
      elixir: "~> 1.18",
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.38.2"},
      {:stream_data, "~> 1.2", only: :test},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
