defmodule LiveviewDemoWeb.PageController do
  use LiveviewDemoWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, LiveViewDemoWeb.DemoLive)
  end
end
