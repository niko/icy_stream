defmodule IcyStream.Mixfile do
  use Mix.Project

  def project do
    [
      app: :icy_streaicy_stream,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "IcyStream",
      source_url: "https://github.com/niko/icy_stream",
      homepage_url: "https://github.com/niko/icy_stream",
      docs: [
        main: "IcyStream", # the main page in the docs
        logo: nil,
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:lhttpc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:lhttpc, "~> 1.3.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
