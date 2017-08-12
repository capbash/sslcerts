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
    * `--post-hook` The script to run after a successful renewal (See `--post-hook` in certbot)

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
            "--non-interactive",
            "--post-hook", post_hook || "touch /tmp/certbot.#{domains |> List.first}.created",
            "--config",
            ini])
       end)
    |> shell_info(raw_args)
  end

  def shell_info({output, _}, opts), do: Shell.info(output, opts)

end
