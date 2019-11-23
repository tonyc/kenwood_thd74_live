defmodule KenwoodD74.Responses do
  @known_responses ~w(
    AE AG AI AS BC BR BL BS BT BY CS DC DL DS DW FO FW FR
    FS FT FV FM FP FS ID IO LC MD ME MR MS PC PS PT RA RT RX SF SH SM
    DQ DR TN TX TY UP VD VG VM VX
  )

  def message_type(raw_message) do
    cond do
      gps_message?(raw_message) ->
        {:ok, {:gps, raw_message}}

      crc_message?(raw_message) ->
        {:ok, {:crc, raw_message}}

      radio_command_response?(raw_message) ->
        {:ok, {:radio_response, raw_message}}

      true ->
        {:error, {:unknown_message, raw_message}}
    end
  end

  def radio_command_response?(command) do
    @known_responses
    |> Enum.include?(String.upcase(command))
  end

  def gps_message?(message) do
    message
    |> String.starts_with?("$GP")
  end

  def crc_message?(message) do
    message
    |> String.starts_with?("$$CRC")
  end
end
