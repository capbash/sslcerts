defmodule Sslcerts.Cli.GetTest do
  use ExUnit.Case
  use Sslcerts.LiveCase
  alias Sslcerts.Cli.Get

  @tag :live
  test "GET some data" do
    {:ok, %{"account" => _}} = Get.run(["/account", "--quiet"])
  end

  @tag :live
  test "GET with attributes" do
    {:ok, %{"images" => _, "links" => _, "meta" => _}} = Get.run(["/images", "--page", "1", "--per-page", "1", "--private", "--quiet"])
  end

end