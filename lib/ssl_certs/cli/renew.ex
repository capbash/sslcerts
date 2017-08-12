defmodule Sslcerts.Cli.Renew do
  use Mix.Task
  use FnExpr
  alias Sslcerts.Io.Shell
  alias Sslcerts.Cli.{Parser, Install}

  @moduledoc"""
  Renew an existing certificate, if no cert exists then create one.

      sslcerts renew

  For more information, take a look at [certbot](https://certbot.eff.org/docs/using.html)

  For scripting, it is best to use this one, as it will create a certificate if
  none exist.

  This also assumes that `bits` has been installed,
  if that's not the case, then ensure that you first run

      sslcerts install bits

  ## Available configurations

    * `--email`     The email associated with the certificate
    * `--domains`   The domains you are certifying
    * `--webroot`   The root of your static assets to allow certbot to confirm it's your domain
    * `--ini`       The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `--keysize`   The size of the certificate key (defaults to 4096)
    * `--post-hook` Any script to run after a successful renewal (See `--renew-hook` in certbot)

  """

  @options %{
    email: :string,
    domains: :list,
    webroot: :string,
    ini: :string,
    keysize: :integer,
    post_hook: :string,
  }

  def run(raw_args) do
    Sslcerts.start
    Install.run(["certbot" | raw_args])

    raw_args
    |> Parser.parse(@options)
    |> invoke(fn {%{ini: ini, post_hook: post_hook, domains: domains}, []} ->
         System.cmd(
           "certbot",
           ["certonly",
            "--expand",
            "--keep-until-expiring",
            "--non-interactive",
            "--renew-hook", post_hook || "touch /tmp/certbot.#{domains |> List.first}.renewed",
            "--config",
            ini])
       end)
    |> shell_info(raw_args)
  end

  def shell_info({output, _}, opts), do: Shell.info(output, opts)

end
