defmodule KenwoodD74 do
  use GenServer

  @impl true
  def init(args \\ "ttyACM0") do
    IO.puts "init(), args: #{inspect args}"
    port = args

    {:ok, pid} = Circuits.UART.start_link  
    Circuits.UART.open(pid, port, speed: 115200, active: true)
    Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r"})

    Process.send_after(self(), :setup, 1000)


    {:ok, %{pid: pid, port: port}}
  end

  def start_link(state \\ %{}) do
    IO.puts "start_link(), state: #{inspect state}"
    GenServer.start_link(__MODULE__, state)
  end

  def handle_info(:circuits_uart, _port, {:error, :eio}, state) do
    IO.puts "Error: IO"
    {:noreply, state}
  end

  def handle_info(:setup, state) do
    IO.puts "handle_info: :setup, setting AI 1, state: #{inspect state}"
    #Circuits.UART.write(state.pid, "")
    #Circuits.UART.write(state.pid, "")
    #Circuits.UART.write(state.pid, "")
    #Circuits.UART.write(state.pid, "")
    Circuits.UART.write(state.pid, "\n\n\nAI 1;")
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, {:error, :eio}}, state) do
    IO.puts "handle_info: IO error"
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, _port,  message}, state) do
    IO.puts "handle_info: #{message}"

    {:noreply, state}
  end

  def handle_info(_) do
    IO.puts "Unknown message"
    {:noreply}
  end
end
