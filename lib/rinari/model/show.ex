defmodule Rinari.Model.Show do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :episodes]}
  schema "shows" do
    field :air_day, :string
    field :air_time, :string
    field :country, :string
    field :imdb_id, :string
    field :tmdb_id, :integer
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

    many_to_many :episodes, Rinari.Model.Episode, join_through: Rinari.Model.ShowEpisode

    timestamps()
  end

  @doc false
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status])
    |> validate_required([:imdb_id, :tmdb_id, :title, :original_title, :synopsis, :runtime, :release_date, :slug, :num_seasons, :country, :network, :last_updated, :air_day, :air_time, :status])
    |> unique_constraint(:imdb_id)
  end
end
