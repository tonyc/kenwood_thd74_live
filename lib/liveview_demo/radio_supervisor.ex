defmodule LiveviewDemo.RadioSupervisor do
  use Supervisor

  require Logger

  def start_link(args) do
    Logger.info("RadioSupervisor.start_link: args: #{inspect args}")
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    Logger.info("RadioSupervisor.init(): args: #{inspect args}")

    children = [
      %{
        id: KenwoodD74,
        start: {KenwoodD74, :start_link, [args]},
        type: :worker,
        restart: :permanent
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
