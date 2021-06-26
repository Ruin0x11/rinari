defmodule Rinari.Model.AnimeTorrent do
  use Rinari.Schema
  import Ecto.Changeset

  schema "animes_torrents" do
    belongs_to :anime, Rinari.Model.Anime
    belongs_to :torrent, Rinari.Model.Torrent
    timestamps()
  end
end

defmodule Rinari.Model.AnimeEpisode do
  use Rinari.Schema
  import Ecto.Changeset

  schema "animes_episodes" do
    belongs_to :anime, Rinari.Model.Anime
    belongs_to :episode, Rinari.Model.Episode
    timestamps()
  end
end

defmodule Rinari.Model.EpisodeTorrent do
  use Rinari.Schema
  import Ecto.Changeset

  schema "episodes_torrents" do
    belongs_to :episode, Rinari.Model.Episode
    belongs_to :torrent, Rinari.Model.Torrent
    timestamps()
  end
end

defmodule Rinari.Model.MovieTorrent do
  use Rinari.Schema
  import Ecto.Changeset

  schema "movies_torrents" do
    belongs_to :movie, Rinari.Model.Movie
    belongs_to :torrent, Rinari.Model.Torrent
    timestamps()
  end
end

defmodule Rinari.Model.ShowTorrent do
  use Rinari.Schema
  import Ecto.Changeset

  schema "shows_torrents" do
    belongs_to :show, Rinari.Model.Show
    belongs_to :torrent, Rinari.Model.Torrent
    timestamps()
  end
end
