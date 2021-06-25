defmodule Rinari.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :provider_id, :integer
      add :name, :string
      add :torrent_provider_id, references(:torrent_providers, on_delete: :nothing)

      timestamps()
    end

    create index(:categories, [:torrent_provider_id])
  end
end
