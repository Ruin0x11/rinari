defmodule Rinari.Model.Anime do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :torrents, :episodes]}
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
    field :original_title, :string
    field :type, Rinari.Model.Enum.AnimeType

    many_to_many :torrents, Rinari.Model.Torrent, join_through: "animes_torrents"
    many_to_many :episodes, Rinari.Model.Episode, join_through: "animes_episodes"

    timestamps()
  end

  @doc false
  def changeset(anime, attrs) do
    anime
    |> cast(attrs, [:kitsu_id, :imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status, :type])
    |> validate_required([:kitsu_id, :imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status, :type])
    |> unique_constraint(:kitsu_id)
  end
end
