defmodule Mix.Tasks.Sslcerts.Renew do
  use Mix.Task

  @shortdoc "Renew an existing certificate"

  @moduledoc"""
  Renew an existing certificate, if no cert exists then create one.

      mix sslcerts.renew

  For more information, take a look at [certbot](https://certbot.eff.org/docs/using.html)

  For scripting, it is best to use this one, as it will create a certificate if
  none exist.

  This also assumes that `bits` has been installed,
  if that's not the case, then ensure that you first run

      mix sslcerts.install bits

  ## Available configurations

    * `--email`     The email associated with the certificate
    * `--domains`   The domains you are certifying
    * `--webroot`   The root of your static assets to allow certbot to confirm it's your domain
    * `--ini`       The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `--keysize`   The size of the certificate key (defaults to 4096)
    * `--post-hook` Any script to run after a successful renewal (See `--renew-hook` in certbot)

  """
  def run(args), do: Sslcerts.Cli.Main.run({:create, args})

end
