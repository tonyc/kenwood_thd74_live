defmodule LiveviewDemo.Repo do
  use Ecto.Repo,
    otp_app: :liveview_demo,
    adapter: Ecto.Adapters.Postgres
end
