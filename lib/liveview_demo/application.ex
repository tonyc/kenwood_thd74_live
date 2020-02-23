# See https://hexdocs.pm/elixir/Application.html for more information on OTP Applications
defmodule LiveviewDemo.Application do
  @moduledoc false

  alias LiveviewDemo.{RadioSupervisor}

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      LiveviewDemoWeb.Endpoint,
      #%{
      #  id: RadioSupervisor,
      #  start: {RadioSupervisor, :start_link, ["ttyACM0"]},
      #  restart: :permanent,
      #  type: :supervisor
      #}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveviewDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiveviewDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
