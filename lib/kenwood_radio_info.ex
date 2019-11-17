defmodule KenwoodD74.RadioInfo do
  @derive Jason.Encoder

  defstruct cmd: "", args: []

  def parse(raw_msg) do
    [command, args] =
      raw_msg
      |> String.split(" ")

    split_args =
      args
      |> String.split(",")

    %__MODULE__{cmd: command, args: split_args}
  end
end
