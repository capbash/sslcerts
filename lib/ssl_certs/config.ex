defmodule Sslcerts.Config do
  use FnExpr

  @moduledoc """
  There are a few ways to configure your SSL certs

  Let's say your host is namedb.org, then you can configure you application
  through Mix Tasks, as follows:

      mix sslcerts.init
      mix sslcerts.config host namedb.org

  And to confirm it's set, run

      mix sslcerts.config

  And the output should look similar to:

      domains: ["FILL_ME_IN.com"]
      email: "YOUR_EMAIL_HERE"
      ini: "/etc/letsencrypt/letsencrypt.ini"
      keysize: 4096

  You can achieve similar behvarious through an iEX session `iex -S mix`

      Sslcerts.Config.init
      "/Users/aforward/.sslcerts"

      Sslcerts.Config.put(:domains, ["namedb.org"])
      :ok

      Sslcerts.Config.read
      %{domains: ["namedb.org"]}

  The information above is cached in the Sslcerts.Worker, so if you are making changes
  in iEX, you can reload your configs using

      iex> Sslcerts.reload
      :ok

  And you can see the currently cached values with

      Sslcerts.config
      %{domains: ["namedb.org"]}

  The order of preference for locating the appropriate configs are

      #1 Environment variable storing the path to the file
      SSLCERTS_CONFIG=/tmp/my.sslcerts

      #2 Elixir built in Mix.Config
      use Mix.Config
      config :sslcerts, config:  %{domains: ["mysite.local"]}

      #3 A file within "myproject" called .sslcerts
      /src/myproject/.sslcerts

      # A file within the home directory called .sslcerts
      ~/.sslcerts

  You could overwrite the location, but that's mostly for testing, so unless you have
  a really valid reason do to so, please don't.
  """

  @default_filename "~/.sslcerts"

  def filename do
    case Application.get_env(:sslcerts, :config) do
      nil ->
        case System.get_env("SSLCERTS_CONFIG") do
          nil -> lookup_filename()
          f -> f
        end
        |> Path.expand()

      _ ->
        :config
    end
  end

  def init(), do: filename() |> init
  def init(:config), do: :config

  def init(filename) do
    :ok = filename |> Path.dirname() |> File.mkdir_p!()

    unless File.exists?(filename) do
      filename |> reinit
    end

    filename
  end

  def reinit(), do: filename() |> reinit
  def reinit(:config), do: :config

  def reinit(filename) do
    :ok = write(filename, default_config())
    filename
  end

  def get(key), do: filename() |> get(key)
  def get(:config, key), do: read() |> Map.get(key)

  def get(filename, key) do
    filename
    |> Path.expand()
    |> init
    |> read
    |> Map.get(key)
  end

  def put(key, value), do: filename() |> put(key, value)
  def put(:config, _key, _value), do: {:error, :readonly}

  def put(filename, key, value) do
    filename
    |> Path.expand()
    |> init
    |> read
    |> Map.merge(%{key => value})
    |> invoke(fn map -> write(filename, map) end)
  end

  def remove(key), do: filename() |> remove(key)
  def remove(:config, _key), do: {:error, :readonly}

  def remove(filename, key) do
    filename
    |> Path.expand()
    |> init
    |> read
    |> Map.delete(key)
    |> invoke(fn map -> write(filename, map) end)
  end

  def read(), do: filename() |> read
  def read(:config), do: Application.get_env(:sslcerts, :config)

  def read(filename) do
    filename
    |> Path.expand()
    |> File.read()
    |> invoke(fn result ->
      case result do
        {:ok, content} -> :erlang.binary_to_term(content)
        {:error, _} -> default_config()
      end
    end)
  end

  defp lookup_filename do
    [
      ".sslcerts"
    ]
    |> Enum.filter(&File.exists?/1)
    |> Enum.fetch(0)
    |> case do
      :error -> @default_filename
      {:ok, f} -> f
    end
  end

  defp write(filename, map) do
    filename
    |> Path.expand()
    |> File.write!(:erlang.term_to_binary(map))
  end

  defp default_config do
    %{
      email: "YOUR_EMAIL_HERE",
      domains: ["FILL_ME_IN.com"],
      ini: "/etc/letsencrypt/letsencrypt.ini",
      keysize: 4096
    }
  end
end
