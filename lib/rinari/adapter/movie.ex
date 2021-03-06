defmodule Rinari.Adapter.Movie do
  alias Rinari.Model.Movie

  defp find_release(tmdb) do
    case get_in(tmdb, ["release_dates", "results"]) do
      nil -> nil
      [] -> nil
      t ->
        us = Enum.find(t, fn r -> r["iso_3166_1"] == "US" end)
        releases = case us do
                     nil -> t |> Enum.flat_map(fn r -> r["release_dates"] end)
                     r -> r["release_dates"]
                   end

        releases
        |> Enum.map(fn r -> Map.update!(r, "release_date", fn d ->
                                {:ok, d, _} = DateTime.from_iso8601(d)
                                DateTime.truncate(d, :second)
                            end)
        end)
        |> Enum.sort_by(fn r -> r["release_date"] end)
        |> Enum.at(0)
    end
  end

  defp find_trailer(tmdb) do
    case get_in(tmdb, ["videos", "results"]) do
      nil -> nil
      [] -> nil
      t -> Enum.find(t, fn v -> v["type"] == "Trailer" && v["site"] == "YouTube" end)
          |> Map.get("key")
          |> (&("http://www.youtube.com/watch?v=#{&1}")).()
    end
  end

  def convert(tmdb) do
    if !tmdb["id"] do
      {:error, "Invalid TMDB entry: #{inspect(tmdb)}"}
    end

    release = find_release(tmdb)

    {:ok, %Movie{
      imdb_id: tmdb["imdb_id"],
      tmdb_id: tmdb["id"],
      title: tmdb["title"],
      original_title: tmdb["original_title"],
      synopsis: tmdb["overview"],
      release_date: release["release_date"],
      certification: release["certification"],
      runtime: tmdb["runtime"],
      trailer: find_trailer(tmdb),
      torrents: []
    }}
  end
end
