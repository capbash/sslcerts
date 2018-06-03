defmodule Sslcerts.Cli.Config do
  use Mix.Task
  alias Sslcerts.Io.Shell

  @moduledoc """
  Reads, updates or deletes Sslcerts configuration keys.

      sslcerts config KEY [VALUE]

  ## Config keys

    * `email`   - The email associated with the certificate
    * `domains` - The domains you are certifying
    * `webroot` - The root of your static assets to allow certbot to confirm it's your domain
    * `ini`     - The path of the certbot configs (defaults to /etc/letsencrypt/letsencrypt.ini)
    * `keysize` - The size of the certificate key (defaults to 4096)
    * `post_hook` - The script to run after a successful create/renewal

  ## Command line options

    * `--delete` - Remove a specific config key

  """

  @switches [delete: :boolean]

  def run(args) do
    {opts, args, _} = OptionParser.parse(args, switches: @switches)

    case args do
      [] ->
        list()

      ["$" <> _key | _] ->
        Mix.raise("Invalid key name")

      [key] ->
        if opts[:delete] do
          delete(key)
        else
          read(key)
        end

      ["domains" | values] ->
        set("domains", values)

      [key, value] ->
        set(key, value)

      [key | values] ->
        set(key, values)

      _ ->
        Shell.raise("""
        Invalid arguments, expected:
        #{Shell.cmd("sslcerts config KEY [VALUE]")}
        """)
    end
  end

  defp list() do
    Enum.each(Sslcerts.Config.read(), fn {key, value} ->
      Shell.info("#{key}: #{inspect(value, pretty: true)}")
    end)
  end

  defp read(key) do
    key
    |> String.to_atom()
    |> Sslcerts.Config.get()
    |> print(key)
  end

  defp print(nil, key) do
    Mix.raise("Config does not contain any value for #{key}")
  end

  defp print(values, key) when is_list(values) do
    values
    |> Enum.join(",")
    |> print(key)
  end

  defp print(value, _key) do
    Shell.info(value)
  end

  defp delete(key) do
    key
    |> String.to_atom()
    |> Sslcerts.Config.remove()
  end

  defp set(key, value) do
    Sslcerts.Config.put(String.to_atom(key), value)
  end
end
