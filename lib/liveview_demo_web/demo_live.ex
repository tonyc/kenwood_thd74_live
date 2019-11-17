defmodule LiveViewDemoWeb.DemoLive do
  use Phoenix.LiveView
  require Logger
  alias Phoenix.Socket.{Broadcast}
  alias KenwoodD74.{RadioInfo}

  @topic "radio"

  @impl true
  def mount(_session, socket) do
    Logger.debug("Liveview mounted")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    end

    {:ok, socket}

    socket = socket
             |> assign(:vfo_a_frequency, "")
             |> assign(:vfo_b_frequency, "")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Logger.debug("render()")

    ~L"""
    <h1 id="vfoA">A: <span class="vfo"><%= @vfo_a_frequency %></span></h1>
    <h1 id="vfoB">B: <span class="vfo"><%= @vfo_b_frequency %></span></h1>
    """
  end

  @impl true
  def handle_info(%Broadcast{event: "radio_info", payload: radio_info}, socket) do
    %RadioInfo{cmd: cmd, args: args} = radio_info
    update_from_command(cmd, args, socket)
  end

  def update_from_command("FQ", ["0" | rest], socket) do
    {:noreply, assign(socket, :vfo_a_frequency, rest)}
  end

  def update_from_command("FQ", ["1" | rest], socket) do
    {:noreply, assign(socket, :vfo_b_frequency, rest)}
  end

  def update_from_command(cmd, args, socket) do
    Logger.info("update_from_command: unknown command: #{inspect cmd}, args: #{inspect args}")
    {:noreply, socket}
  end

end
