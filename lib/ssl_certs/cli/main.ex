defmodule Sslcerts.Cli.Main do
  use FnExpr
  alias Sslcerts.Io.Shell

  def main(argv) do
    argv
    |> parse
    |> run
  end

  def run({:sslcerts, _}) do
    Shell.info "sslcerts v" <> Sslcerts.version
    Shell.info "sslcerts allows elixir/phoenix apps to easily create SSL certs (using Let's Encrypt and Certbot)."
    Shell.newline

    Shell.info "Available tasks:"
    Shell.newline
    # Run `mix help --search sslcerts.` to get this output
    # and paste here, replacing `mix sslcerts.` with just `sslcerts `
    Shell.info "#{Shell.cmd("sslcerts config")} # Reads, updates or deletes Sslcerts config"
    Shell.info "#{Shell.cmd("sslcerts init")}   # Initialize your sslcerts config"

    Shell.newline

    Shell.info "Further information can be found here:"
    Shell.info "  -- https://hex.pm/packages/sslcerts"
    Shell.info "  -- https://github.com/capbash/sslcerts"
    Shell.newline
  end

  # TODO: consider moving to macro expansion
  def run({:config, args}), do: Sslcerts.Cli.Config.run(args)
  def run({:init, args}), do: Sslcerts.Cli.Init.run(args)
  def run({unknown_cmd, _args}) do
    Shell.error "Unknown command, #{unknown_cmd}, check spelling and try again"
    Shell.newline
    Shell.newline
    run({:sslcerts, []})
  end

  defp parse([]), do: {:sslcerts, []}
  defp parse([subcommand | subargs]) do
    subcommand
    |> String.replace(".", "_")
    |> String.to_atom
    |> invoke({&1, subargs})
  end

end