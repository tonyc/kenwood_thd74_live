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

    {:ok, assign(socket, :radio_info, encode(%RadioInfo{}))}
  end

  @impl true
  def render(assigns) do
    Logger.debug("render()")

    ~L"""
    <h1><%= @radio_info %></h1>
    """
  end

  @impl true
  def handle_info(%Broadcast{event: "radio_info", payload: radio_info}, socket) do
    {:noreply, assign(socket, :radio_info, encode(radio_info))}
  end

  defp encode(thing) do
    Jason.encode!(thing)
  end

end
