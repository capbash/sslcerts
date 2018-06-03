defmodule Mix.Tasks.Sslcerts.Init do
  use Mix.Task

  @shortdoc "Initialize your sslcerts config"

  @moduledoc """
  Initialize your sslcerts config

       mix sslcerts.init

  See `mix help sslcerts.config` to see all available configuration options.
  """
  def run(args), do: Sslcerts.Cli.Main.run({:init, args})
end
