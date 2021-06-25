defmodule Rinari.ProviderStrategies do
  alias Rinari.Model

  defp media_to_media_type(media) do
    Rinari.Utils.entity_to_typed_id(media)
  end

  defp media_to_category(media) do
    case media do
      %Model.Movie{} -> {2000, "movie-search"} # "Movies"
      %Model.Show{} -> {5000, "tv-search"} # "TV"
      %Model.Anime{} -> {5070, "search"} # "TV/Anime"
    end
  end

  defp search_to_query_type(search) do
    case search do
      "movie-search" -> "movie"
      "tv-search" -> "tvsearch"
      x -> x
    end
  end

  defp find_capable_indexers(client, category, search) do
    with {:ok, indexers} <- client |> Rinari.Jackett.configured_indexers do
      indexers
      |> Enum.filter(fn i -> Enum.find(i["caps"], fn c -> c["ID"] == "#{category}" end) end)
      |> Enum.map(fn i -> {i, client |> Rinari.Jackett.Api.Results.caps(i["id"]) |> elem(1)} end)
      |> Enum.filter(fn {_, caps} -> caps["caps"]["searching"][search]["available"] == "yes" end)
      |> (&({:ok, &1})).()
    end
  end

  defp make_query(media) do
    "#{media.title} #{media.release_date.year}"
  end

  defp get_strategy(media, indexer, category, search, caps) do
    params = caps["caps"]["searching"][search]["supportedParams"] |> String.split(",") |> MapSet.new
    categories = [category] |> Enum.join(",")
    strategy = cond do
      "imdbid" in params -> %{type: :imdb, imdb_id: media.imdb_id}
      true -> %{type: :search, categories: categories, query: make_query(media)}
    end
    Map.merge(strategy, %{media_type: media_to_media_type(media), media_id: media.id, indexer_id: indexer["id"], query_type: search_to_query_type(search)})
  end

  def get_strategies(media_type, media_id) do
    Rinari.Utils.typed_id_to_entity(media_type, media_id)
    |> get_strategies
  end

  def get_strategies(media) do
    {cat, search} = media_to_category(media)
    client = Rinari.Jackett.client

    with {:ok, capable_indexers} <- find_capable_indexers(client, cat, search) do
      capable_indexers
      |> Enum.map(fn {i, caps} -> get_strategy(media, i, cat, search, caps) end)
      |> (&({:ok, &1})).()
    end
  end
end
