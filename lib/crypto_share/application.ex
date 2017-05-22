defmodule CryptoShare.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, CryptoShare.Router, [], [port: 4000])
    ]

    opts = [strategy: :one_for_one, name: CryptoShare.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
