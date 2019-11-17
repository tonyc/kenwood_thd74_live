defmodule KenwoodD74.RadioInfo do
  defstruct command: "", args: []

  def parse(raw_msg) do
    [command, args] =
      raw_msg
      |> String.split(" ")

    split_args =
      args
      |> String.split(",")

    %__MODULE__{command: command, args: split_args}
  end
end
