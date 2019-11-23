# See https://hexdocs.pm/elixir/Application.html for more information on OTP Applications
defmodule LiveviewDemo.Application do
  @moduledoc false

  import Supervisor.Spec

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      LiveviewDemo.Repo,
      # Start the endpoint when the application starts
      LiveviewDemoWeb.Endpoint,
      supervisor(LiveviewDemo.RadioSupervisor, ["ttyACM0"])
      # Starts a worker by calling: LiveviewDemo.Worker.start_link(arg)
      # {LiveviewDemo.Worker, arg},
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
