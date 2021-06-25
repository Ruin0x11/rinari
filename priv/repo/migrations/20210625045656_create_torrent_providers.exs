defmodule Rinari.Repo.Migrations.CreateTorrentProviders do
  use Ecto.Migration

  def change do
    create table(:torrent_providers) do
      add :name, :string
      add :human_name, :string
      add :link, :string
      add :configured, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:torrent_providers, [:name])
  end
end
