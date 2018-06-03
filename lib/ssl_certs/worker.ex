defmodule Sslcerts.Worker do
  use GenServer

  @moduledoc """
  Provides global access to the loaded configs, the API
  is available directly with `Sslcerts`, so there is little need to
  dive too deep into here to learn how to use the API, but
  rather for understanding the internals of the project.

  To lookup the loaded configs (or to load them for the first time),

        Sslcerts.config

  Which will call

        GenServer.call(Sslcerts.Worker, :config)

  To force a reload on the global configs,

        Sslcerts.reload

  Which will call

        GenServer.call(Sslcerts.Worker, :reload)

  If you wanted to load a different config file, then,

        Sslcerts.reload("/path/to/new/file.sslcerts")

  Which will call

        GenServer.call(Sslcerts.Worker, {:reload, "/path/to/new/file.sslcerts"})
  """

  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:config, _from, state) do
    case state[:config] do
      nil -> read_config(state)
      c -> {:reply, c, state}
    end
  end

  def handle_call(:reload, _from, _state) do
    {:reply, :ok, %{config: Sslcerts.Config.read()}}
  end

  def handle_call({:reload, filename}, _from, _state) do
    {:reply, :ok, %{config: Sslcerts.Config.read(filename)}}
  end

  defp read_config(state) do
    config = Sslcerts.Config.read()
    {:reply, config, Map.put(state, :config, config)}
  end
end
