defmodule Rinari.Model.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "abstract table: episodes" do
    field :assoc_id, :integer
    field :episode, :integer
    field :first_aired, :utc_datetime
    field :overview, :string
    field :season, :integer
    field :title, :string
    field :tmdb_id, :integer

    has_many :torrents, {"episode_torrents", Rinari.Model.Torrent}, foreign_key: :assoc_id

    timestamps()
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:assoc_id, :season, :episode, :first_aired, :title, :overview, :tmdb_id])
    |> validate_required([:assoc_id, :season, :episode, :first_aired, :title, :overview, :tmdb_id])
  end
end
