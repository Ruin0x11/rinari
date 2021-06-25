defmodule Rinari.Model.Torrent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "torrents" do
    field :assoc_id, :integer
    field :provider_link, :string
    field :publish_date, :utc_datetime
    field :size, :integer
    field :title, :string
    field :url, :string
    field :seeders, :integer
    field :peers, :integer
    field :torrent_provider_id, :id
    field :type, Rinari.Model.Enum.TorrentType

    timestamps()
  end

  @doc false
  def changeset(torrent, attrs) do
    torrent
    |> cast(attrs, [:assoc_id, :url, :size, :title, :publish_date, :provider_link, :type])
    |> validate_required([:assoc_id, :url, :size, :title, :publish_date, :provider_link, :type])
  end
end
