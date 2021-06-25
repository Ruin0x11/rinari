defmodule Rinari.Model.Movie do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :torrents]}
  schema "movies" do
    field :certification, :string
    field :imdb_id, :string
    field :tmdb_id, :integer
    field :release_date, :utc_datetime
    field :runtime, :integer
    field :synopsis, :string
    field :title, :string
    field :original_title, :string
    field :trailer, :string

    many_to_many :torrents, Rinari.Model.Torrent, join_through: "movies_torrents"

    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :certification, :trailer])
    |> validate_required([:imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :trailer])
    |> unique_constraint(:imdb_id)
  end
end
