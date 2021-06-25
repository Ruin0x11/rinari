defmodule Rinari.Model.Anime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "animes" do
    field :air_day, :string
    field :air_time, :string
    field :country, :string
    field :imdb_id, :string
    field :tmdb_id, :integer
    field :kitsu_id, :string
    field :last_updated, :utc_datetime
    field :network, :string
    field :num_seasons, :integer
    field :release_date, :utc_datetime
    field :runtime, :integer
    field :slug, :string
    field :status, :string
    field :synopsis, :string
    field :title, :string
    field :type, Rinari.Model.Enum.AnimeType

    has_many :torrents, {"anime_torrents", Rinari.Model.Torrent}, foreign_key: :assoc_id
    has_many :episodes, {"anime_episodes", Rinari.Model.Episode}, foreign_key: :assoc_id

    timestamps()
  end

  @doc false
  def changeset(anime, attrs) do
    anime
    |> cast(attrs, [:kitsu_id, :imdb_id, :tmdb_id, :title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status, :type])
    |> validate_required([:kitsu_id, :imdb_id, :tmdb_id, :title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status, :type])
    |> unique_constraint(:kitsu_id)
  end
end
