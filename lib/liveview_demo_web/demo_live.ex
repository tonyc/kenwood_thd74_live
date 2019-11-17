defmodule LiveViewDemoWeb.DemoLive do
  use Phoenix.LiveView
  require Logger
  alias Phoenix.Socket.{Broadcast}

  @topic "radio"

  @impl true
  def mount(_session, socket) do
    Logger.debug("Liveview mounted")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    end

    {:ok, assign(socket, :current_time, DateTime.utc_now())}
  end

  @impl true
  def render(assigns) do
    Logger.debug("render()")

    ~L"""
    <h1>At the tone, the time will be <%= @current_time %></h1>
    <h1>Beep.</h1>
    """
  end

  @impl true
  def handle_info(%Broadcast{event: _message} = broadcast, socket) do
    IO.puts "***** handled broadcast: #{inspect broadcast}"



    {:noreply, socket}
  end

end
