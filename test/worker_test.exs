defmodule Sslcerts.WorkerTest do
  use ExUnit.Case

  alias Sslcerts.Worker

  setup do
    on_exit fn ->
      Application.delete_env(:sslcerts, :config)
      Sslcerts.reload
    end
    :ok
  end

  test "Store :config in worker" do
    Application.put_env(:sslcerts, :config, %{host: "mysite.local"})
    Sslcerts.reload
    assert GenServer.call(Worker, :config) == %{host: "mysite.local"}

    Application.put_env(:sslcerts, :config, %{host: "mynewsite.local"})
    assert GenServer.call(Worker, :config) == %{host: "mysite.local"}

    GenServer.call(Worker, :reload)
    assert GenServer.call(Worker, :config) == %{host: "mynewsite.local"}
  end
end