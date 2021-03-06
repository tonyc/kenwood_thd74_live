defmodule LiveViewDemoWeb.DemoLive do
  use Phoenix.LiveView
  require Logger
  alias Phoenix.Socket.{Broadcast}
  alias KenwoodD74.{RadioInfo}
  alias KenwoodD74

  alias LiveviewDemoWeb.PageView

  @topic "radio"

  @impl true
  def mount(_session, socket) do
    Logger.debug("Liveview mounted")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    end

    {:ok, socket}

    socket =
      socket
      |> assign(:vfo_a_frequency, "0")
      |> assign(:vfo_a_squelch_open, false)
      |> assign(:vfo_b_frequency, "0")
      |> assign(:vfo_b_squelch_open, false)
      |> assign(:current_vfo, :a)
      |> assign(:audio_gain, "006")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    PageView.render("radio.html", assigns)
  end

  @impl true
  def handle_event("mic_up", _meta, socket) do
    KenwoodD74.radio_up()
    {:noreply, socket}
  end

  def handle_event("mic_dn", _meta, socket) do
    KenwoodD74.radio_down()

    {:noreply, socket}
  end

  def handle_event("set_vfo_a", _meta, socket) do
    KenwoodD74.set_vfo_a()

    {:noreply, socket}
  end

  def handle_event("set_vfo_b", _meta, socket) do
    KenwoodD74.set_vfo_b()

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Broadcast{event: "radio_info", payload: radio_info}, socket) do
    %RadioInfo{cmd: cmd, args: args} = radio_info
    update_from_command(cmd, args, socket)
  end

  def update_from_command("BC", ["0"], socket) do
    {:noreply, assign(socket, :current_vfo, :a)}
  end

  def update_from_command("BC", ["1"], socket) do
    {:noreply, assign(socket, :current_vfo, :b)}
  end

  def update_from_command("BY", ["0", status], socket) do
    {:noreply, assign(socket, :vfo_a_squelch_open, status == "1")}
  end

  def update_from_command("BY", ["1", status], socket) do
    {:noreply, assign(socket, :vfo_b_squelch_open, status == "1")}
  end

  def update_from_command("FQ", ["0" | rest], socket) do
    freq = rest |> List.first()

    {:noreply, assign(socket, :vfo_a_frequency, freq)}
  end

  def update_from_command("FQ", ["1" | rest], socket) do
    freq = rest |> List.first()
    {:noreply, assign(socket, :vfo_b_frequency, freq)}
  end

  def update_from_command("AG", [audio_gain], socket) do
    {:noreply, assign(socket, :audio_gain, audio_gain)}
  end

  def update_from_command(cmd, args, socket) do
    Logger.info("update_from_command: unknown command: #{inspect(cmd)}, args: #{inspect(args)}")
    {:noreply, socket}
  end
end
