defmodule Sslcerts.Cli.ParserTest do
  use ExUnit.Case
  alias Sslcerts.Cli.Parser

  setup do
    on_exit fn ->
      File.rm("/tmp/parser.sslcerts")
      System.delete_env("SSLCERTS_CONFIG")
      Sslcerts.reload
    end
    :ok
  end

  @opt_defn %{one: :string, two: :boolean, four: :list}

  test "parse empty" do
    assert {%{}, []} == Parser.parse([] ,%{})
    assert {%{}, ["dosomething"]} == Parser.parse(["dosomething"] ,%{})
  end

  test "parse string, boolean and list" do
    args = ["dox", "--one" , "1", "--two", "three", "--four", "a,b,c"]
    assert {%{four: ["a", "b", "c"], one: "1", two: true}, ["dox", "three"]}
      == Parser.parse(args, @opt_defn)
  end

  test "parse integer" do
    assert {%{five: 0}, []} == Parser.parse([], %{five: :integer})
  end

  test "defaulted values (no overrides)" do
    args = ["dox", "three"]
    assert {%{four: [], one: nil, two: false}, ["dox", "three"]}
      == Parser.parse(args, @opt_defn)
  end

  test "no option definition" do
    args = ["dox", "--a" , "1", "--b", "three", "--c", "a,b,c"]
    assert {%{a: "1", b: "three", c: "a,b,c"}, ["dox"]}
      == Parser.parse(args)
  end

  test "defaulted values (with overrides)" do
    System.put_env("SSLCERTS_CONFIG", "/tmp/parser.sslcerts")
    Sslcerts.Config.put(:one, "uno")
    Sslcerts.Config.put(:two, true)
    Sslcerts.Config.put(:four, ["d", "e", "f"])

    args = ["dox", "--one" , "1", "--two", "three", "--four", "a,b,c"]
    assert {%{four: ["a", "b", "c"], one: "1", two: true}, ["dox", "three"]}
      == Parser.parse(args, @opt_defn)

    args = ["dox", "three"]
    assert {%{four: ["d", "e", "f"], one: "uno", two: true}, ["dox", "three"]}
      == Parser.parse(args, @opt_defn)
  end

end