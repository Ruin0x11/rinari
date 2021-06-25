defmodule Rinari.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :season, :integer
      add :episode, :integer
      add :first_aired, :utc_datetime
      add :title, :string
      add :overview, :text
      add :tmdb_id, :integer

      timestamps()
    end
  end
end
