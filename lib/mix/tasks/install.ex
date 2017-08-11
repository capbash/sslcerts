defmodule Mix.Tasks.Sslcerts.Install do
  use Mix.Task

  @shortdoc "Install / Initialize your server to generate SSL certs"

  @moduledoc"""
  Install / Initialize your server to generate SSL certs

      sslcerts install

  This will install the [bits](https://github.com/capbash/bits) to help with installing other apps,
  as well as certbot itself.  To only install bits, run

      sslcerts install bits

  And, then to separately install certbot, run

      sslcerts install certbot

  ## Available configurations

    * `--email`     The email associated with the certificate
    * `--domains`   The domains you are certifying
    * `--webroot`   The root of your static assets to allow certbot to confirm it's your domain
    * `--ini`       The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `--keysize`   The size of the certificate key (defaults to 4096)

  """
  def run(args), do: Sslcerts.Cli.Main.run({:install, args})

end
