defmodule Rinari.Model.TorrentProvider do
  use Ecto.Schema
  import Ecto.Changeset

  schema "torrent_providers" do
    field :configured, :boolean, default: false
    field :human_name, :string
    field :link, :string
    field :name, :string

    has_many :torrents, Rinari.Model.Torrent
    has_many :categories, Rinari.Model.Category

    timestamps()
  end

  @doc false
  def changeset(torrent_provider, attrs) do
    torrent_provider
    |> cast(attrs, [:name, :human_name, :link, :configured])
    |> validate_required([:name, :human_name, :link, :configured])
    |> unique_constraint(:name)
  end
end
