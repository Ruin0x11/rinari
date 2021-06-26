defmodule RinariWeb.TorrentView do
  use RinariWeb, :view
  alias Rinari.Model.{Movie, Show}

  def render("media_torrents.json", %{torrents: torrents, media: media, mode: mode}) do
    %{
      "en" =>
      Enum.map(torrents, fn torrent ->
        {torrent.quality, render_one(torrent, __MODULE__, "torrent.json", media: media, mode: mode)}
      end)
      |> Enum.into(%{})
    }
  end

  def render("torrent.json", %{torrent: torrent, media: media, mode: mode}) do
    base = %{
      url: torrent.url,
      provider: "test",
    }

    base = if mode == :torrents do
      Map.merge(base, %{title: torrent.title, source: torrent.provider_link})
    else
      base
    end

    case media do
      %Movie{} -> Map.merge(base, %{
                                    seed: torrent.seeders,
                                    peer: torrent.peers,
                                    size: torrent.size,
                                    filesize: Size.humanize!(torrent.size)
                            })
      %Show{} ->
        m = %{seeds: torrent.seeders, peers: torrent.peers}
        m = if torrent.file, do: Map.put(m, :file, torrent.file)
        Map.merge(base, m)
      m -> m
    end
  end
end
