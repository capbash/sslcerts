defmodule Sslcerts do

  @moduledoc"""

  # Sslcerts

  An elixir wrapper to [Let's Encrypt](https://letsencrypt.org/) and [Certbot](https://certbot.eff.org/) for SSL certification management.

  This library is sufficiently opinionated, so to learn more about how to integrate Let's Encrypt
  SSL certs into your project without having to follow the style of this project, please
  refer to [Phoenix/Elixir App Secured with Let’s Encrypt](https://medium.com/@a4word/phoenix-app-secured-with-let-s-encrypt-469ac0995775)

  This wrapper provides two basic functions.

  * Create a new certification for your site
  * Replace an existing and soon to expiore certification for your site

  This is meant to be run on your production server, and as this library expands, will include
  managing certifications across multiple boxes.

  ## Installation

  ### Command Line (Latest Version)

  To install the `sslcerts` command line tool (whose only dependency is Erlang), then
  you can [install it using escript](https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Install.html).


  ```bash
  # Install from GitHub
  mix escript.install github capbash/sslcerts

  # Install form HEX.pm
  mix escript.install hex sslcerts
  ```

  If you see a warning like

  ```bash
  warning: you must append "~/.mix/escripts" to your PATH
  if you want to invoke escripts by name
  ```

  Then, make sure to update your PATH variable.  Here's how on a Mac OS X, but each
  [environment is slightly different](https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path).

  ```bash
  vi ~/.bash_profile

  # Add a line like the following
  PATH="$HOME/.mix/escripts:$PATH"
  export PATH
  ```

  Start a new terminal session. You will know it's working when you can *find* it using *where*

  ```
  where sslcerts
  ```

  ### Command Line (Other Versions)

  To install a specific version, branch, tag or commit, adjust any one of the following

  ```bash
  # Install from a specific version
  mix escript.install hex sslcerts 1.2.3

  # Install from the latest of a specific branch
  mix escript.install github capbash/sslcerts branch git_branch

  # Install from a specific tag
  mix escript.install github capbash/sslcerts tag git_tag

  # Install from a specific commit
  mix escript.install github capbash/sslcerts ref git_ref
  ```

  Again, checkout [mix escript.install](https://hexdocs.pm/mix/Mix.Tasks.Escript.Install.html) for
  more information about installing global tasks.

  ### Mix Tasks

  More likley, you will have an Elixir phoenix application and you can
  add a dependency to your `mix.exs` file.

  ```elixir
  @deps [
    sslcerts: "~> 0.1.0"
  ]
  ```

  This will give you access to `sslcerts *` tasks (instead of globally installing
  the `sslcerts` escript). You will also have programtic access from your `Sslcerts` module
  as well; so you could expose feature directly within your application as well.

  ## Configure Host

  Before you can use the sslcerts, you will need to configure your host / domain name that
  you are trying to secure.

  Let's say your domain is namedb.org, then configure it as follows:

      # using escript
      sslcerts init
      sslcerts config host namedb.org

      # using mix tasks
      sslcerts init
      sslcerts config host namedb.org

  And to confirm it's set, run

      sslcerts config

  And the output should look similar to:

      host: "namedb.org"

  ## Available Commands / Tasks

  To get help on the available commands, run

      # using escript
      sslcerts

      # using mix tasks
      mix sslcerts

  The output will look similar to the following

      sslcerts v0.1.0
      sslcerts allows elixir/phoenix apps to easily create SSL certs (using Let's Encrypt and Certbot).

      Available tasks:

      sslcerts config  # Reads, updates or deletes Sslcerts config
      sslcerts init    # Initialize your sslcerts config
      sslcerts install # Generate certbot certificate on your server

      Further information can be found here:
        -- https://hex.pm/packages/sslcerts
        -- https://github.com/capbash/sslcerts

  Please note that the mix tasks and sslcerts scripts provide identical functionality,
  they are just structured slightly differently.

  In general,

  * `mix sslcerts.<sub command> <options> <args>` for mix tasks
  * `sslcerts <sub command> <options> <args>` for escript

  Make sure that have installed sslcerts correctly for mix tasks (if you want to use mix
  tasks), or escript (if you want to use escript).

  ## Elixir API

  These features are also available from within Elixir through `Sslcerts` modules,
  this gives you better programatic access to return data (presented as a map),
  but in most cases probably is not required to automate your infrastructure.

  If we start an iEX session in your project that includes the sslcerts dependency,
  you can access the same information in Elixir.

      iex> Sslcerts.config
      %{token: "FILL_ME_IN.com"}

  This is the first release, which just manages the configs.  Concrete implemetation
  (and supporting documentation) coming soon.

  The underlying configs are stored in `Sslcerts.Worker` ([OTP GenServer](https://elixir-lang.org/getting-started/mix-otp/genserver.html)).
  If you change your configurations and need them reloaded, then call
  and can be reloaded using

      iex> Sslcerts.reload

  """

  def version(), do: unquote(Mix.Project.config[:version])
  def elixir_version(), do: unquote(System.version)

  def start(), do: {:ok, _started} = Application.ensure_all_started(:sslcerts)


  @doc"""
  Retrieve the SSLCERTS configs.
  """
  def config do
    GenServer.call(Sslcerts.Worker, :config)
  end

  @doc"""
  Reload the SSLCERTS configs from the defaulted location
  """
  def reload, do: GenServer.call(Sslcerts.Worker, :reload)
  def reload(filename), do: GenServer.call(Sslcerts.Worker, {:reload, filename})

end
