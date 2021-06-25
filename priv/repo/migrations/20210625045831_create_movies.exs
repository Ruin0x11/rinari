defmodule Rinari.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :imdb_id, :string
      add :tmdb_id, :integer
      add :title, :string
      add :synopsis, :string
      add :runtime, :integer
      add :release_date, :utc_datetime
      add :certification, :string
      add :trailer, :string

      timestamps()
    end

    create unique_index(:movies, [:imdb_id])
  end
end
