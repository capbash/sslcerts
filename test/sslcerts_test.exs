defmodule SslcertsTest do
  use ExUnit.Case

  setup do
    on_exit(fn ->
      Application.delete_env(:sslcerts, :config)
      Sslcerts.reload()
    end)

    :ok
  end

  test "versions" do
    assert Sslcerts.version() == Mix.Project.config()[:version]
    assert Sslcerts.elixir_version() == System.version()
  end

  test "config (from worker)" do
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"]})
    Sslcerts.reload()
    assert Sslcerts.config() == %{domains: ["mysite.local"]}

    Application.put_env(:sslcerts, :config, %{domains: ["mynewsite.local"]})
    assert Sslcerts.config() == %{domains: ["mysite.local"]}

    Sslcerts.reload()
    assert Sslcerts.config() == %{domains: ["mynewsite.local"]}
  end
end
