defmodule Rinari.Processor.Search do
  @behaviour Rinari.Processor

  alias Broadway.Message

  @impl Rinari.Processor
  def type, do: :search

  @impl Rinari.Processor
  def process(%Message{data: %{query: query}} = message) do
    case Rinari.Utils.movie_title_to_entity(query) do
      {:ok, movie} ->
        Rinari.Elastic.Client.put(movie)
        Rinari.Utils.index_torrents(movie)
        message
      e -> Message.failed(message, "Could not search #{inspect(e)}")
    end
  end
end
