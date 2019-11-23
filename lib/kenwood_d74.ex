defmodule KenwoodD74 do
  use GenServer
  require Logger
  alias KenwoodD74.{RadioInfo, Responses}

  @topic "radio"

  # Client API

  def start_link(args) do
    Logger.info("KenwoodD74.start_link(), args: #{inspect(args)}")
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def radio_up do
    send_command("UP")
  end

  def radio_down do
    send_command("DW")
  end

  def set_vfo_a do
    send_command("BC 0")
  end

  def set_vfo_b do
    send_command("BC 1")
  end

  def send_command(cmd) do
    Logger.info("client: send_command()")
    GenServer.cast(__MODULE__, {:send_cmd, cmd})
  end

  # Server API

  @impl true
  def init(port) do
    Logger.info("KenwoodD74.init(), args: #{inspect(port)}")

    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, port, speed: 115_200, active: true)
    Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r"})

    Process.send_after(self(), :setup, 1000)

    {:ok, %{pid: pid, port: port}}
  end

  @impl true
  def handle_cast({:send_cmd, command}, state) do
    Logger.info("handle_cast: send_cmd(): #{inspect(command)}, state: #{inspect(state)}")

    Circuits.UART.write(state.pid, command)

    {:noreply, state}
  end

  @impl true
  def handle_info(:setup, state) do
    Logger.info("handle_info: :setup, setting AI 1, state: #{inspect(state)}")
    Circuits.UART.write(state.pid, "AI 1")
    Process.sleep(500)
    Circuits.UART.write(state.pid, "AI 1")
    Process.sleep(500)
    Circuits.UART.write(state.pid, "AI 1")

    Logger.info("Done attempting to set AI 1")

    {:noreply, state}
  end

  # Circuits.UART messages

  # Stop on i/o error from the radio
  def handle_info({:circuits_uart, _port, {:error, :eio}}, state) do
    {:stop, :io_error, state}
  end

  def handle_info({:circuits_uart, _port, message}, state) do
    message_no_newlines =
      message
      |> String.replace("\r\n", "\n")
      |> String.replace("\n", "")

    case Responses.message_type(message_no_newlines) do
      {:ok, {:gps, msg}} ->
        Logger.info("GPS: #{inspect(msg)}")

      {:ok, {:crc, msg}} ->
        Logger.info("CRC: #{inspect(msg)}")

      {:ok, {:radio_response, msg}} ->
        Logger.info("Radio: #{inspect(msg)}")

        msg
        |> RadioInfo.parse()
        |> broadcast()

      {:error, {:unknown_message, msg}} ->
        Logger.warn("Unknown message: #{inspect(msg)}")
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unknown message: #{inspect(msg)}")

    {:noreply, state}
  end

  defp broadcast(%RadioInfo{} = radio_info) do
    LiveviewDemoWeb.Endpoint.broadcast(@topic, "radio_info", radio_info)
  end
end
