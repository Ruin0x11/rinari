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

    many_to_many :torrents, Rinari.Model.Torrent, join_through: Rinari.Model.MovieTorrent

    embeds_one :cover_image_set, Rinari.Model.Embedded.CoverImageSet

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

defimpl Elasticsearch.Document, for: Rinari.Model.Movie do
  def id(movie), do: movie.id
  def routing(_), do: false
  def encode(movie) do
    %{
      id: movie.id,
      title: movie.title,
      imdb_id: movie.imdb_id,
      genres: ["unknown"],
      year: movie.release_date.year,
      created: movie.inserted_at,
      released: movie.release_date.year,
      locales: [],
      rating: []
    }
  end
end
