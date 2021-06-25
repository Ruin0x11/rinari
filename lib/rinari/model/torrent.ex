defmodule Rinari.Model.Torrent do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "torrents" do
    field :provider_link, :string
    field :publish_date, :utc_datetime
    field :size, :integer
    field :provider_title, :string
    field :url, :string
    field :seeders, :integer
    field :peers, :integer
    field :quality, :string
    field :file, :string
    field :torrent_provider_id, :id
    field :type, Rinari.Model.Enum.TorrentType

    timestamps()
  end

  @doc false
  def changeset(torrent, attrs) do
    torrent
    |> cast(attrs, [:url, :size, :provider_title, :publish_date, :provider_link, :type, :seeders, :peers, :quality, :file])
    |> validate_required([:url, :size, :provider_title, :publish_date, :provider_link, :type, :seeders, :peers, :quality])
  end
end
