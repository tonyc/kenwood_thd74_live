defmodule LiveViewDemoWeb.DemoLive do
  use Phoenix.LiveView
  require Logger

  def mount(_session, socket) do
    Logger.debug("*** MOUNT ***")

    {:ok, assign(socket, :current_time, DateTime.utc_now())}
  end

  def render(assigns) do
    Logger.debug("render()")

    ~L"""
    <h1>At the tone, the time will be <%= @current_time %></h1>
    <h1>Beep.</h1>
    """
  end

end
