defmodule LiveviewDemo.RadioSupervisor do
  use Supervisor

  require Logger

  def start_link(args) do
    Logger.info("RadioSupervisor.start_link: args: #{inspect args}")
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    Logger.info("RadioSupervisor.init(): args: #{inspect args}")

    children = [
      worker(KenwoodD74, [args], restart: :permanent)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
