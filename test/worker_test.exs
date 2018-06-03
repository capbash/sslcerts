defmodule Sslcerts.WorkerTest do
  use ExUnit.Case

  alias Sslcerts.Worker

  setup do
    on_exit(fn ->
      Application.delete_env(:sslcerts, :config)
      Sslcerts.reload()
    end)

    :ok
  end

  test "Store :config in worker" do
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"]})
    Sslcerts.reload()
    assert GenServer.call(Worker, :config) == %{domains: ["mysite.local"]}

    Application.put_env(:sslcerts, :config, %{domains: ["mynewsite.local"]})
    assert GenServer.call(Worker, :config) == %{domains: ["mysite.local"]}

    GenServer.call(Worker, :reload)
    assert GenServer.call(Worker, :config) == %{domains: ["mynewsite.local"]}
  end
end
