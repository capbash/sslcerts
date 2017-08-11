defmodule Sslcerts.Cli.Install do
  use Mix.Task
  use FnExpr
  alias Sslcerts.Io.Shell
  alias Sslcerts.Cli.Parser

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

  """

  @options %{
    email: :string,
    domains: :list,
    webroot: :string,
  }

  def run(raw_args) do
    Sslcerts.start
    raw_args
    |> Parser.parse(@options)
    |> install_script
  end

  def install_script({opts, []}) do
    install_script({opts, ["bits"]})
    install_script({opts, ["certbot"]})
  end

  def install_script({opts, ["bits"]}) do
    {_, 0} = System.cmd("curl", ["-s", "https://raw.githubusercontent.com/capbash/bits/master/bits-installer", "-o", "/tmp/bits-installer.sh"])
    System.cmd("/tmp/bits-installer.sh", [])
    |> shell_info(opts)
  end

  def install_script({%{email: email, domains: domains, webroot: webroot} = opts, ["certbot"]}) do
    System.cmd("bits", ["install-if", "certbot"])
    |> shell_info(opts)

    System.cmd(
      "bits",
      ["install", "certbotcert"],
      env: %{"EMAIL" => email,
             "DOMAINS" => domains |> Enum.join(","),
             "WEBROOT" => webroot})
    |> shell_info(opts)
  end

  def shell_info({output, _}, opts), do: Shell.info(output, opts)

end
