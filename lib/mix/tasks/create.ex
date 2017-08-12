defmodule Mix.Tasks.Sslcerts.Create do
  use Mix.Task

  @shortdoc "Create a new certificate"

  @moduledoc"""
  Create a new certificate

      mix sslcerts.create

  This assumes that `bits` has been installed, if that's not the case, then ensure that you first run

      mix sslcerts.install bits

  ## Available configurations

    * `--email`     The email associated with the certificate
    * `--domains`   The domains you are certifying
    * `--webroot`   The root of your static assets to allow certbot to confirm it's your domain
    * `--ini`       The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `--keysize`   The size of the certificate key (defaults to 4096)
    * `--post-hook` Any script to run after a successful renewal (See `--post-hook` in certbot)

  """
  def run(args), do: Sslcerts.Cli.Main.run({:create, args})

end
