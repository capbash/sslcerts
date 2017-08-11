defmodule Sslcerts.Cli.Create do
  use Mix.Task
  use FnExpr
  alias Sslcerts.Io.Shell
  alias Sslcerts.Cli.{Parser, Install}

  @moduledoc"""
  Create a new certificate

      sslcerts create

  This assumes that `bits` has been installed, if that's not the case, then ensure that you first run

      sslcerts install bits

  ## Available configurations

    * `--email`     The email associated with the certificate
    * `--domains`   The domains you are certifying
    * `--webroot`   The root of your static assets to allow certbot to confirm it's your domain
    * `--ini`       The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `--keysize`   The size of the certificate key (defaults to 4096)

  """

  @options %{
    email: :string,
    domains: :list,
    webroot: :string,
    ini: :string,
    keysize: :integer,
  }

  def run(raw_args) do
    Sslcerts.start
    Install.run(["certbot" | raw_args])

    raw_args
    |> Parser.parse(@options)
    |> invoke(fn {%{ini: ini}, []} ->
         System.cmd(
           "certbot",
           ["certonly",
            "--non-interactive",
            "--config",
            ini])
       end)
    |> shell_info(raw_args)
  end

  def shell_info({output, _}, opts), do: Shell.info(output, opts)

end
