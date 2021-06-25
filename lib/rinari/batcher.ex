defmodule Rinari.Batcher do
  @callback type :: String.t
  @callback batch(Broadway.Message.t, Broadway.BatchInfo.t) :: Broadway.Message.t

  def all do
    with {:ok, list} <- :application.get_key(:rinari, :modules) do
      list
      |> Enum.filter(& &1 |> Module.split |> Enum.take(2) == ~w|Rinari Batcher|)
      |> Enum.filter(& &1 |> Module.split |> length == 3)
    end
  end

  def for_type(type) do
    Rinari.Batcher.all |> Enum.find(fn m -> m.type == type end)
  end
end
