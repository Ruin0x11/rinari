defmodule Rinari.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :imdb_id, :string
      add :tmdb_id, :integer
      add :title, :string
      add :original_title, :string
      add :synopsis, :text
      add :runtime, :integer
      add :release_date, :utc_datetime
      add :certification, :string
      add :trailer, :string
      add :cover_image_set, :map

      timestamps()
    end

    create unique_index(:movies, [:imdb_id])
  end
end
