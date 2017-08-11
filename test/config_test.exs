defmodule Sslcerts.ConfigTest do
  use ExUnit.Case, async: false
  doctest Sslcerts.Config

  alias Sslcerts.Config

  @filename "/tmp/here/.sslcerts"
  @default_config %{host: "FILL_ME_IN.com"}

  setup do
    on_exit fn ->
      File.rm(".sslcerts")
      File.rm("~/.sslcerts" |> Path.expand)
      File.rm("/tmp/.sslcerts")
      File.rm_rf("/tmp/here")
      System.delete_env("SSLCERTS_CONFIG")
      Application.delete_env(:sslcerts, :config)
      Sslcerts.reload
    end
    :ok
  end

  test "filename (default)" do
    assert Config.filename == "~/.sslcerts" |> Path.expand
  end

  test "filename (local directory)" do
    File.touch(".sslcerts")
    assert Config.filename == ".sslcerts" |> Path.expand
  end

  test "filename (SYSTEM ENV)" do
    File.touch(".sslcerts")
    System.put_env("SSLCERTS_CONFIG", @filename)
    assert Config.filename == @filename
  end

  test "filename (Application ENV)" do
    File.touch(".sslcerts")
    Application.put_env(:sslcerts, :config, %{host: "mysite.local"})
    assert Config.filename == :config
  end

  test "init (use default filename)" do
    System.put_env("SSLCERTS_CONFIG", @filename)
    Config.init
    assert File.exists?(@filename)
    assert @default_config == Config.read
  end

  test "init (file exists -- do nothing)" do
    System.put_env("SSLCERTS_CONFIG", "/tmp/.sslcerts")
    File.write!("/tmp/.sslcerts", "xxx")
    Config.init
    assert "xxx" == File.read!("/tmp/.sslcerts")
  end

  test "init (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{host: "mysite.local"})
    Config.init
    assert %{host: "mysite.local"} == Config.read
  end

  test "reinit (file exists -- overwrite)" do
    System.put_env("SSLCERTS_CONFIG", "/tmp/.sslcerts")
    File.write!("/tmp/.sslcerts", "xxx")
    Config.reinit
    assert @default_config == Config.read
  end

  test "reinit (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{host: "mysite.local"})
    Config.reinit
    assert %{host: "mysite.local"} == Config.read
  end

  test "edit configs" do
    @filename |> Config.init

    :ok = Config.put(@filename, :host, "MY_NEW_SITE.local")
    assert "MY_NEW_SITE.local" == Config.get(@filename, :host)
    assert my_config(%{host: "MY_NEW_SITE.local"}) == Config.read(@filename)

    assert nil == Config.get(@filename, :apples)

    :ok = Config.put(@filename, :ssh_keys, ["abc", "def"])
    assert ["abc", "def"] == Config.get(@filename, :ssh_keys)
    assert my_config(%{ssh_keys: ["abc", "def"], host: "MY_NEW_SITE.local"}) == Config.read(@filename)

    :ok = Config.remove(@filename, :ssh_keys)
    assert nil == Config.get(@filename, :ssh_keys)
    assert %{host: "MY_NEW_SITE.local"} == Config.read(@filename)

  end

  test "get (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{host: "mysite.local", ssh_keys: ["ab1", "ab2"]})
    assert ["ab1", "ab2"] == Config.get(:config, :ssh_keys)
    assert %{host: "mysite.local", ssh_keys: ["ab1", "ab2"]} == Config.read(:config)

    assert ["ab1", "ab2"] == Config.get(:ssh_keys)
    assert %{host: "mysite.local", ssh_keys: ["ab1", "ab2"]} == Config.read
  end

  defp my_config(changes), do: Map.merge(@default_config, changes)

end
