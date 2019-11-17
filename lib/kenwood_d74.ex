defmodule KenwoodD74 do
  use GenServer

  alias KenwoodD74.{RadioInfo}

  @topic "radio"

  @impl true
  def init(args \\ "ttyACM0") do
    IO.puts("init(), args: #{inspect(args)}")
    port = args

    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, port, speed: 115_200, active: true)
    Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r"})

    Process.send_after(self(), :setup, 1000)

    {:ok, %{pid: pid, port: port}}
  end

  def start_link(state \\ %{}) do
    IO.puts("start_link(), state: #{inspect(state)}")
    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:circuits_uart, _port, {:error, :eio}, state) do
    IO.puts("Error: IO")
    {:noreply, state}
  end

  def handle_info(:setup, state) do
    IO.puts("handle_info: :setup, setting AI 1, state: #{inspect(state)}")
    Circuits.UART.write(state.pid, "AI 1")
    Circuits.UART.write(state.pid, "AI 1")
    Circuits.UART.write(state.pid, "AI 1")
    Circuits.UART.write(state.pid, "AI 1")

    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, {:error, :eio}}, state) do
    IO.puts("handle_info: IO error")
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, message}, state) do
    IO.puts("handle_info: #{message}")

    message
    |> RadioInfo.parse()
    |> broadcast()

    {:noreply, state}
  end

  def handle_info(_) do
    IO.puts("Unknown message")
    {:noreply}
  end

  defp broadcast(%RadioInfo{} = info) do
    LiveviewDemoWeb.Endpoint.broadcast(@topic, "radio_info", %{payload: info})
  end
end
