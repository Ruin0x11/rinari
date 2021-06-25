defmodule Rinari.Model.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies" do
    field :certification, :string
    field :imdb_id, :string
    field :tmdb_id, :integer
    field :release_date, :utc_datetime
    field :runtime, :integer
    field :synopsis, :string
    field :title, :string
    field :trailer, :string

    has_many :torrents, {"movie_torrents", Rinari.Model.Torrent}, foreign_key: :assoc_id

    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:imdb_id, :tmdb_id, :title, :synopsis, :runtime, :release_date, :certification, :trailer])
    |> validate_required([:imdb_id, :tmdb_id, :title, :synopsis, :runtime, :release_date, :trailer])
    |> unique_constraint(:imdb_id)
  end
end
