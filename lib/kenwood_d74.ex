defmodule KenwoodD74 do
  use GenServer
  require Logger
  alias KenwoodD74.{RadioInfo}

  @server __MODULE__
  @topic "radio"

  # Client API

  def start_link(args) do
    Logger.info("KenwoodD74.start_link(), args: #{inspect(args)}")
    GenServer.start_link(@server, args, name: @server)
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
    GenServer.cast(@server, {:send_cmd, cmd})
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
    Circuits.UART.write(state.pid, "AI 1")
    Circuits.UART.write(state.pid, "AI 1")
    Circuits.UART.write(state.pid, "AI 1")

    Logger.info("Done attempting to set AI 1")

    {:noreply, state}
  end

  # Circuits.UART messages

  # Stop on i/o error from the radio
  def handle_info({:circuits_uart, _port, {:error, :eio}}, state) do
    {:stop, :io_error, state}
  end

  def handle_info({:circuits_uart, _port, "?"}, state) do
    Logger.info("Got '?' from radio")
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _port, "RX"}, state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _port, "DW"}, state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _port, "UP"}, state) do
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _port, "$GP" <> _rest = message}, state) do
    Logger.info("GPS: #{inspect(message)}")
    {:noreply, state}
  end

  def handle_info(
        {:circuits_uart, _port,
         "$$CRC" <> <<crc_byte_1::size(16), crc_byte_2::size(16), ",", message::binary>>},
        state
      ) do
    Logger.info(
      "#{__MODULE__}: found CRC message (#{inspect(crc_byte_1)}, #{inspect(crc_byte_2)}): #{
        inspect(message)
      }"
    )

    {:noreply, state}
  end

  # Handles parseable radio messages (those with more than one word)
  # TODO: Discern between APRS, D-Star, GPS, and standard Kenwood CAT messages
  def handle_info({:circuits_uart, _port, message}, state) do
    Logger.info("handle_info: :circuits_uart: unknown message: #{message}")

    message
    |> RadioInfo.parse()
    |> broadcast()

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
