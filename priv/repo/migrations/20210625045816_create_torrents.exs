defmodule Rinari.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    Rinari.Model.Enum.TorrentType.create_type

    Enum.map(["movie"], fn name ->
      id = String.to_atom("#{name}_torrents")
      create table(id) do
        add :assoc_id, :integer
        add :url, :string
        add :size, :integer
        add :title, :string
        add :publish_date, :utc_datetime
        add :provider_link, :string
        add :torrent_provider_id, references(:torrent_providers, on_delete: :nothing)
        add :type, Rinari.Model.Enum.TorrentType.type()

        timestamps()
      end

      create unique_index(id, [:assoc_id])
      create index(id, [:torrent_provider_id])
    end)
  end
end
