defmodule Mix.Tasks.Sslcerts do
  use Mix.Task

  @shortdoc "Print the help for managing your SSL certifications"

  @moduledoc"""
  Print the help for managing your SSL certifications

       mix sslcerts

  See `mix help sslcerts.config` to see all available configuration options.
  """

  def run(args), do: Sslcerts.Cli.Main.run({:sslcerts, args})

end
