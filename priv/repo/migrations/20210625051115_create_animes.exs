defmodule Rinari.Repo.Migrations.CreateAnimes do
  use Ecto.Migration

  def change do
    Rinari.Model.Enum.AnimeType.create_type

    create table(:animes) do
      add :kitsu_id, :string
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
      add :type, Rinari.Model.Enum.AnimeType.type()

      timestamps()
    end

    create unique_index(:animes, [:kitsu_id])
  end
end
