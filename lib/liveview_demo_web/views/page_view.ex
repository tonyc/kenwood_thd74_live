defmodule LiveviewDemoWeb.PageView do
  use LiveviewDemoWeb, :view

  def format_frequency(freq) do
    {mhz, _rest} = Float.parse(freq)

    (mhz / 1_000_000)
    |> to_string()
    |> String.pad_trailing(7, "0")
  end

  def vfo_indicator(current_vfo, test_vfo) do
    if current_vfo == test_vfo do
      "PTT"
    else
      ""
    end
  end

  def squelch_state_to_percentage(state) do
    case state do
      false -> 0
      _ -> 100
    end
  end

  def format_volume(volume_string) do
    {vol, _} = Integer.parse(volume_string)

    vol
    |> scale(6, 193, 0, 100)
    |> trunc()
  end

  def scale(val, rmin, rmax, tmin, tmax) do
    ((val - rmin) / (rmax - rmin)) * (tmax - tmin) + tmin
  end
end
