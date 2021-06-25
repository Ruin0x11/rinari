defmodule Rinari.Repo.Migrations.CreateShows do
  use Ecto.Migration

  def change do
    create table(:shows) do
      add :imdb_id, :string
      add :tmdb_id, :integer
      add :title, :string
      add :synopsis, :string
      add :runtime, :integer
      add :release_date, :utc_datetime
      add :slug, :string
      add :num_seasons, :integer
      add :country, :string
      add :network, :string
      add :last_updated, :utc_datetime
      add :air_day, :string
      add :air_time, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:shows, [:imdb_id])
  end
end
