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

  def install_script({%{email: email, domains: domains, webroot: webroot, ini: ini, keysize: keysize} = opts, ["certbot"]}) do
    System.cmd("bits", ["install-if", "certbot"])
    |> shell_info(opts)

    :ok = ini |> Path.expand |> Path.dirname |> File.mkdir_p!

    ini
    |> Path.expand
    |> File.write!("""
rsa-key-size = #{keysize}
email = #{email}
domains = #{domains |> Enum.join(" ")}
text = True
authenticator = webroot
preferred-challenges = http-01
webroot-path = #{webroot}
       """)

    Shell.info("Updated certbot #{ini}")
  end

  def shell_info({output, _}, opts), do: Shell.info(output, opts)
end
