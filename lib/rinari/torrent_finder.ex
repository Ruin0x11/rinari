defmodule Rinari.TorrentFinder do
  alias Rinari.Model.{Movie, Show, Anime}
  alias Rinari.Repo

  defp media_to_torrent_type(media) do
    case media do
      %Movie{} -> :movie
      %Show{} -> :show
      %Anime{type: type} -> type
    end
  end

  defp to_torrent(result, media) do
    url = Tesla.get!(result["link"]) |> Tesla.get_header("location")
    attrs = result["{http://torznab.com/schemas/2015/feed}attr"]
    |> Enum.map(fn e -> {e["name"], e["value"]} end)
    |> Enum.into(%{})

    Ecto.build_assoc(
      media,
      :torrents,
      url: url,
      size: result["size"] |> Integer.parse |> elem(0),
      title: result["title"],
      provider_link: result["guid"],
      publish_date: result["pubDate"] |> Timex.parse("%a, %d %b %Y %H:%M:%S %z", :strftime),
      seeders: attrs["seeders"] |> Integer.parse |> elem(0),
      peers: attrs["seeders"] |> Integer.parse |> elem(0),
      type: media_to_torrent_type(media)
    )
  end

  defp contains?(s, match) do
    s =~ ~r/#{match}/i
  end

  defp torrent_matches(torrent, media) do
    title = torrent.title
    (contains?(title, media.title)
      || contains?(title, media.original_title))
    && (contains?(title, "#{media.release_date.year}"))
  end

  defp to_torrents(results, media) do
    case results |> Enum.find(fn i -> elem(i, 0) == "item" end) do
      nil -> []
      x -> elem(x, 1)
      |> Enum.map(fn r -> to_torrent(r, media) end)
    end
  end

  defp find_search(client, %{indexer_id: indexer_id, query: q, query_type: t, categories: cat}, media) do
    with {:ok, results} <- client |> Rinari.Jackett.Api.Results.search(indexer_id, q: q, t: t, cat: cat) do
      results
      |> to_torrents(media)
      |> Enum.filter(fn r -> torrent_matches(r, media) end)
      |> (&({:ok, &1})).()
    end
  end

  defp find_imdb(client, %{indexer_id: indexer_id, imdb_id: imdb_id, query_type: t}, media) do
    with {:ok, results} <- client |> Rinari.Jackett.Api.Results.search(indexer_id, imdbid: imdb_id, t: t) do
      results
      |> to_torrents(media)
      |> (&({:ok, &1})).()
    end
  end

  defp get_media(id, type) do
    mod = case type do
      :movie -> Movie
      :tv -> Show
      :anime -> Anime
    end
    Repo.get!(mod, id)
  end

  def find_torrents(%{type: type, media_id: media_id, media_type: media_type} = strategy) do
    client = Rinari.Jackett.client
    media = get_media(media_id, media_type)

    case type do
      :search -> find_search(client, strategy, media)
      :imdb -> find_imdb(client, strategy, media)
    end
  end
end
