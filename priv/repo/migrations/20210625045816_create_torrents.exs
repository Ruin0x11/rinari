defmodule Rinari.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    Rinari.Model.Enum.TorrentType.create_type

    create table(:torrents) do
      add :url, :text
      add :size, :bigint
      add :provider_title, :string
      add :publish_date, :utc_datetime
      add :provider_link, :string
      add :seeders, :integer
      add :peers, :integer
      add :quality, :string
      add :file, :string
      add :torrent_provider_id, references(:torrent_providers, on_delete: :nothing)
      add :type, Rinari.Model.Enum.TorrentType.type()

      timestamps()
    end

    create index(:torrents, [:torrent_provider_id])
  end
end
