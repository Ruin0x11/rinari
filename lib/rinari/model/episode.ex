defmodule Rinari.Model.Episode do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :torrents]}
  schema "abstract table: episodes" do
    field :episode, :integer
    field :first_aired, :utc_datetime
    field :overview, :string
    field :season, :integer
    field :title, :string
    field :tmdb_id, :integer

    many_to_many :torrents, Rinari.Model.Torrent, join_through: "episodes_torrents"

    timestamps()
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:season, :episode, :first_aired, :title, :overview, :tmdb_id])
    |> validate_required([:season, :episode, :first_aired, :title, :overview, :tmdb_id])
  end
end
