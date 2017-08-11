defmodule Sslcerts.Mixfile do
  use Mix.Project

  @app :sslcerts
  @git_url "https://github.com/capbash/sslcerts"
  @home_url @git_url
  @version "0.2.1"

  @deps [
    {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    {:poison, "~> 3.1.0"},
    {:httpoison, "~> 0.11.1"},
    {:fn_expr, "~> 0.2"},
    {:version_tasks, "~> 0.10"},
    {:ex_doc, ">= 0.0.0", only: :dev},
  ]

  @aliases [
  ]

  @package [
    name: @app,
    files: ["lib", "mix.exs", "README*", "LICENSE*"],
    maintainers: ["Andrew Forward"],
    licenses: ["MIT"],
    links: %{"GitHub" => @git_url}
  ]

  @escript [
    main_module: Sslcerts.Cli.Main
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod
    [
      app:     @app,
      version: @version,
      elixir:  "~> 1.4",
      name: @app,
      description: "Allows elixir/phoenix apps to easily create SSL certs (using Let's Encrypt and Certbot)",
      package: @package,
      source_url: @git_url,
      homepage_url: @home_url,
      docs: [main: "Sslcerts",
             extras: ["README.md"]],
      build_embedded:  in_production,
      start_permanent:  in_production,
      deps:    @deps,
      aliases: @aliases,
      escript: @escript,
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  def application do
    [
      mod: { Sslcerts.Application, [] },
      extra_applications: [
        :logger
      ],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

end
