defmodule FakeKenwoodD74 do
  use GenServer
  require Logger

  alias KenwoodD74.{RadioInfo}

  @topic "radio"
  @timer_interval 10 
  @messages [
    "FQ 0,0442075000",
    "SM 0,0",
    "SM 0,0",
    "MD 0,6",
    "FQ 0,0462562500",
    "SF 0,5",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0462587500",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0462637500",
    "SM 0,0",
    "FQ 0,0462662500",
    "SM 0,0",
    "FQ 0,0462687500",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0462712500",
    "SM 0,0",
    "SM 0,0",
    "FQ 1,0467562500",
    "FQ 1,0467587500",
    "FQ 1,0467612500",
    "SM 0,0",
    "FQ 0,0467637500",
    "SM 0,0",
    "FQ 0,0467662500",
    "SM 0,0",
    "SM 0,0",
    "FQ 1,0467712500",
    "SM 0,0",
    "FQ 0,0462550000",
    "SM 0,0",
    "SM 0,0",
    "FQ 1,0462575000",
    "SM 0,0",
    "FQ 0,0462625000",
    "SM 0,0",
    "FQ 0,0462650000",
    "SM 0,0",
    "SM 0,0",
    "FQ 1,0462675000",
    "FQ 0,0462700000",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0462725000",
    "SM 0,0",
    "MD 0,0",
    "FQ 1,0145250000",
    "SF 0,0",
    "SM 0,0",
    "FQ 0,0145290000",
    "FQ 1,0145310000",
    "FQ 1,0145370000",
    "FQ 1,0145390000",
    "FQ 1,0145450000",
    "FQ 1,0146700000",
    "FQ 0,0146760000",
    "FQ 0,0146850000",
    "FQ 0,0146985000",
    "FQ 0,0147030000",
    "FQ 0,0147060000",
    "FQ 0,0147120000",
    "FQ 0,0147165000",
    "FQ 0,0147210000",
    "FQ 0,0147330000",
    "FQ 0,0145230000",
    "FQ 0,0223900000",
    "SF 0,7",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0223940000",
    "FQ 0,0442075000",
    "SF 0,0",
    "SM 0,0",
    "FQ 0,0443000000",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0444075000",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0444100000",
    "FQ 0,0444125000",
    "FQ 0,0444425000",
    "SM 0,0",
    "FQ 0,0444475000",
    "FQ 0,0444525000",
    "SM 0,0",
    "FQ 0,0444750000",
    "SM 0,0",
    "FQ 0,0145170000",
    "SM 0,0",
    "FQ 0,0444175000",
    "FQ 0,0145430000",
    "FQ 0,0444200000",
    "SM 0,0",
    "FQ 0,0444375000",
    "SM 0,0",
    "FQ 0,0146415000",
    "FQ 0,0146430000",
    "FQ 0,0146445000",
    "FQ 0,0146460000",
    "FQ 0,0146475000",
    "FQ 0,0146520000",
    "FQ 0,0146535000",
    "FQ 0,0146565000",
    "FQ 0,0146580000",
    "FQ 0,0146595000",
    "FQ 0,0147420000",
    "FQ 0,0147435000",
    "FQ 0,0147450000",
    "FQ 0,0147465000",
    "FQ 0,0147510000",
    "FQ 0,0147540000",
    "FQ 0,0147555000",
    "FQ 0,0147570000",
    "FQ 0,0147585000",
    "FQ 0,0222350000",
    "SM 0,0",
    "FQ 0,0223500000",
    "FQ 0,0223520000",
    "FQ 0,0223540000",
    "FQ 0,0223560000",
    "SM 0,0",
    "FQ 0,0223580000",
    "FQ 0,0223600000",
    "FQ 0,0223620000",
    "FQ 0,0223640000",
    "FQ 0,0223660000",
    "FQ 0,0223680000",
    "FQ 0,0223700000",
    "FQ 0,0223720000",
    "FQ 0,0223740000",
    "FQ 0,0442075000",
    "SM 0,0",
    "MD 0,6",
    "FQ 0,0462562500",
    "SF 0,5",
    "SM 0,0",
    "FQ 0,0462587500",
    "SM 0,0",
    "FQ 0,0462637500",
    "FQ 0,0462662500",
    "SM 0,0",
    "FQ 0,0462687500",
    "SM 0,0",
    "FQ 0,0462712500",
    "SM 0,0",
    "FQ 0,0467562500",
    "FQ 0,0467587500",
    "FQ 0,0467612500",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0467637500",
    "FQ 0,0467662500",
    "SM 0,0",
    "SM 0,0",
    "FQ 0,0467712500",
    "FQ 0,0462550000",
    "SM 0,0",
    "FQ 0,0462575000",
    "FQ 0,0462625000",
    "SM 0,0"
  ]

  def start_link(state \\ %{}) do
    Logger.info("start_link")
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(_args) do
    Logger.info("init")
    :timer.send_interval(@timer_interval, self(), :generate_message)

    {:ok, %{idx: 0, total: Enum.count(@messages)}}
  end

  @impl true
  def handle_info(:generate_message, %{idx: idx, total: total} = state) do
    @messages
    |> Enum.at(idx)
    |> RadioInfo.parse()
    |> broadcast()

    new_index = rem(idx + 1, total)

    {:noreply, %{state | idx: new_index}}
  end

  defp broadcast(%RadioInfo{} = radio_info) do
    LiveviewDemoWeb.Endpoint.broadcast(@topic, "radio_info", radio_info)
  end
end
