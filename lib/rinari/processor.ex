defmodule Rinari.Processor do
  @callback type :: String.t
  @callback process :: Broadway.Message

  def all do
    with {:ok, list} <- :application.get_key(:rinari, :modules) do
      list
      |> Enum.filter(& &1 |> Module.split |> Enum.take(2) == ~w|Rinari Processor|)
      |> Enum.filter(& &1 |> Module.split |> length == 3)
    end
  end

  def for_type(type) do
    Rinari.Processor.all |> Enum.find(fn m -> m.type == type end)
  end
end
