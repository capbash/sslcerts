defmodule Mix.Tasks.Sslcerts.Config do
  use Mix.Task

  @shortdoc "Reads, updates or deletes Sslcerts config"

  @moduledoc"""
  Reads, updates or deletes Sslcerts configuration keys.

      sslcerts config KEY [VALUE]

  ## Config keys

    * `host` - The host you are trying to secure (e.g. mysite.com)

  ## Command line options

    * `--delete` - Remove a specific config key

  """

  def run(args), do: Sslcerts.Cli.Main.run({:config, args})

end
