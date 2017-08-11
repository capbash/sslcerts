defmodule Mix.Tasks.Sslcerts.Config do
  use Mix.Task

  @shortdoc "Reads, updates or deletes Sslcerts config"

  @moduledoc"""
  Reads, updates or deletes Sslcerts configuration keys.

      sslcerts config KEY [VALUE]

  ## Config keys

    * `email`   - The email associated with the certificate
    * `domains` - The domains you are certifying
    * `webroot` - The root of your static assets to allow certbot to confirm it's your domain
    * `ini`     - The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `keysize` - The size of the certificate key (defaults to 4096)

  ## Command line options

    * `--delete` - Remove a specific config key

  """

  def run(args), do: Sslcerts.Cli.Main.run({:config, args})

end
