defmodule Rinari.Processor.Search do
  @behaviour Rinari.Processor

  @impl Rinari.Processor
  def type, do: "search"

  def process(message) do
    IO.puts("In a search")
    message
  end
end
