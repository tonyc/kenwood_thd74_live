defmodule FakeKenwoodD74 do
  use GenServer
  require Logger

  alias KenwoodD74.{RadioInfo}

  @topic "radio"

  def start_link(state \\ %{}) do
    Logger.info("start_link")
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(_args) do
    Logger.info("init")

    Process.send_after(self(), :setup, 100)

    {:ok, %{}}
  end

  def handle_info(:setup, state) do
    {:noreply, state}
  end

  defp broadcast(%RadioInfo{} = radio_info) do
    LiveviewDemoWeb.Endpoint.broadcast(@topic, "radio_info", radio_info)
  end


end
