defmodule Mix.Tasks.SslcertsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "run without args shows help" do
    assert capture_io(fn ->
      Mix.Tasks.Sslcerts.run([])
    end) =~ "sslcerts v#{Sslcerts.version}"
  end

end
