defmodule KenwoodD74.RadioInfo do
  @derive Jason.Encoder
  require Logger

  defstruct cmd: "", args: []

  def parse(raw_msg) do
    parts =
      raw_msg
      |> String.split(" ")

    case parts do
      [cmd] ->
        %__MODULE__{cmd: cmd, args: []}

      [cmd | args] ->
        Logger.debug("parse: cmd: #{inspect(cmd)}, args: #{inspect(args)}")

        exploded_args =
          args
          |> List.first()
          |> String.split(",")

        %__MODULE__{cmd: cmd, args: exploded_args}

      _ ->
        %__MODULE__{cmd: "", args: []}
    end
  end
end
