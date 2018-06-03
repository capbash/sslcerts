defmodule Sslcerts.ConfigTest do
  use ExUnit.Case, async: false
  doctest Sslcerts.Config

  alias Sslcerts.Config

  @filename "/tmp/here/.sslcerts"
  @default_config %{
    email: "YOUR_EMAIL_HERE",
    domains: ["FILL_ME_IN.com"],
    ini: "/etc/letsencrypt/letsencrypt.ini",
    keysize: 4096
  }

  setup do
    on_exit(fn ->
      File.rm(".sslcerts")
      File.rm("~/.sslcerts" |> Path.expand())
      File.rm("/tmp/.sslcerts")
      File.rm_rf("/tmp/here")
      System.delete_env("SSLCERTS_CONFIG")
      Application.delete_env(:sslcerts, :config)
      Sslcerts.reload()
    end)

    :ok
  end

  test "filename (default)" do
    assert Config.filename() == "~/.sslcerts" |> Path.expand()
  end

  test "filename (local directory)" do
    File.touch(".sslcerts")
    assert Config.filename() == ".sslcerts" |> Path.expand()
  end

  test "filename (SYSTEM ENV)" do
    File.touch(".sslcerts")
    System.put_env("SSLCERTS_CONFIG", @filename)
    assert Config.filename() == @filename
  end

  test "filename (Application ENV)" do
    File.touch(".sslcerts")
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"]})
    assert Config.filename() == :config
  end

  test "init (use default filename)" do
    System.put_env("SSLCERTS_CONFIG", @filename)
    Config.init()
    assert File.exists?(@filename)
    assert @default_config == Config.read()
  end

  test "init (file exists -- do nothing)" do
    System.put_env("SSLCERTS_CONFIG", "/tmp/.sslcerts")
    File.write!("/tmp/.sslcerts", "xxx")
    Config.init()
    assert "xxx" == File.read!("/tmp/.sslcerts")
  end

  test "init (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"]})
    Config.init()
    assert %{domains: ["mysite.local"]} == Config.read()
  end

  test "reinit (file exists -- overwrite)" do
    System.put_env("SSLCERTS_CONFIG", "/tmp/.sslcerts")
    File.write!("/tmp/.sslcerts", "xxx")
    Config.reinit()
    assert @default_config == Config.read()
  end

  test "reinit (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"]})
    Config.reinit()
    assert %{domains: ["mysite.local"]} == Config.read()
  end

  test "edit configs" do
    @filename |> Config.init()

    :ok = Config.put(@filename, :domains, ["MY_NEW_SITE.local", "dev.MY_NEW_SITE.local"])
    assert ["MY_NEW_SITE.local", "dev.MY_NEW_SITE.local"] == Config.get(@filename, :domains)

    assert my_config(%{domains: ["MY_NEW_SITE.local", "dev.MY_NEW_SITE.local"]}) ==
             Config.read(@filename)

    assert nil == Config.get(@filename, :apples)

    :ok = Config.put(@filename, :email, "my_new_email")
    assert "my_new_email" == Config.get(@filename, :email)

    assert my_config(%{
             email: "my_new_email",
             domains: ["MY_NEW_SITE.local", "dev.MY_NEW_SITE.local"]
           }) == Config.read(@filename)

    :ok = Config.remove(@filename, :email)
    assert nil == Config.get(@filename, :email)

    assert %{
             domains: ["MY_NEW_SITE.local", "dev.MY_NEW_SITE.local"],
             ini: "/etc/letsencrypt/letsencrypt.ini",
             keysize: 4096
           } == Config.read(@filename)
  end

  test "get (Application :config -- do nothing)" do
    Application.put_env(:sslcerts, :config, %{domains: ["mysite.local"], email: "myemail"})
    assert "myemail" == Config.get(:config, :email)
    assert %{domains: ["mysite.local"], email: "myemail"} == Config.read(:config)

    assert "myemail" == Config.get(:email)
    assert %{domains: ["mysite.local"], email: "myemail"} == Config.read()
  end

  defp my_config(changes), do: Map.merge(@default_config, changes)
end
