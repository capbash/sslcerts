defmodule Sslcerts.LiveCase do

  defmacro __using__(_) do
    quote do
      setup do
        System.put_env("SSLCERTS_CONFIG", "~/.sslcerts.live")
        Sslcerts.reload
        on_exit fn ->
          System.delete_env("SSLCERTS_CONFIG")
          Sslcerts.reload
        end
        :ok
      end
    end
  end

end