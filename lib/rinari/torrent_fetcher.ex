defmodule Rinari.TorrentFetcher do
  alias Rinari.Model.{Movie, Show, Anime, Torrent}

  @limit 10

  defp media_to_torrent_type(media) do
    case media do
      %Movie{} -> :movie
      %Show{} -> :show
      %Anime{type: type} -> type
    end
  end

  defp to_torrent(result, metadata, media) do
    url = Tesla.get!(result["link"]) |> Tesla.get_header("location")
    attrs = result["{http://torznab.com/schemas/2015/feed}attr"]
    |> Enum.map(fn e -> {e["name"], e["value"]} end)
    |> Enum.into(%{})
    {:ok, publish_date} = result["pubDate"] |> Timex.parse("%a, %d %b %Y %H:%M:%S %z", :strftime)
    IO.inspect(metadata)

    %Torrent{
      url: url,
      size: result["size"] |> Integer.parse |> elem(0),
      provider_title: result["title"],
      provider_link: result["guid"],
      publish_date: publish_date,
      seeders: attrs["seeders"] |> Integer.parse |> elem(0),
      peers: attrs["seeders"] |> Integer.parse |> elem(0),
      quality: resolution_to_quality(metadata[:resolution]),
      type: media_to_torrent_type(media)
    }
  end

  defp resolution_to_quality(resolution) do
    resolution
  end

  defp can_index(_raw, metadata, media) do
    title = metadata[:title] || ""
    (title =~ ~r/^#{media.title}$/i || title =~ ~r/^#{media.original_title}$/i)
    && metadata[:resolution] != nil
  end

  defp to_torrents(results, media) do
    case results |> Enum.find(fn i -> elem(i, 0) == "item" end) do
      nil -> []
      x -> elem(x, 1)
      |> Enum.map(fn r -> {r, TorrentDissect.parse(r["title"])} end)
      |> Enum.filter(fn {r, metadata} -> can_index(r, metadata, media) end)
      |> Enum.map(fn {r, metadata} -> to_torrent(r, metadata, media) end)
    end
  end

  defp fetch_search(client, %{indexer_id: indexer_id, query: q, query_type: t, categories: cat}, media) do
    with {:ok, results} <- client |> Rinari.Jackett.Api.Results.search(indexer_id, q: q, t: t, cat: cat, limit: @limit) do
      results
      |> to_torrents(media)
      |> (&({:ok, &1, media})).()
    end
  end

  defp fetch_imdb(client, %{indexer_id: indexer_id, imdb_id: imdb_id, query_type: t}, media) do
    with {:ok, results} <- client |> Rinari.Jackett.Api.Results.search(indexer_id, imdbid: imdb_id, t: t, limit: @limit) do
      results
      |> to_torrents(media)
      |> (&({:ok, &1, media})).()
    end
  end

  def fetch_torrents(%{type: type, media_type: media_type, media_id: media_id} = strategy) do
    client = Rinari.Jackett.client
    media = Rinari.Utils.typed_id_to_entity(media_type, media_id)

    case type do
      "search" -> fetch_search(client, strategy, media)
      "imdb" -> fetch_imdb(client, strategy, media)
    end
  end
end
