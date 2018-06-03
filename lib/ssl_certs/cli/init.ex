defmodule Sslcerts.Cli.Init do
  @moduledoc """
  Initialize your sslcerts config
  """

  def run(_) do
    filename = Sslcerts.Config.init()
    IO.puts("SSLCERTS config initialized, and stored in")
    IO.puts("  -- #{filename}")
    IO.puts("")
  end
end
