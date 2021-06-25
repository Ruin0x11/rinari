defmodule Rinari.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require AMQP

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Rinari.Repo,
      # Start the Telemetry supervisor
      RinariWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Rinari.PubSub},
      # Start the Endpoint (http/https)
      RinariWeb.Endpoint,
      {Rinari.MessageQueue, []},
      Rinari.Schemas
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinari.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RinariWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
