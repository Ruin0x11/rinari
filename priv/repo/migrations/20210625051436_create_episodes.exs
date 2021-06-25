defmodule Rinari.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    Enum.each(["show", "anime"], fn name ->
      id = String.to_atom("#{name}_episodes")
      create table(id) do
        add :season, :integer
        add :episode, :integer
        add :first_aired, :utc_datetime
        add :title, :string
        add :overview, :text
        add :tmdb_id, :integer

        timestamps()
      end
    end)
  end
end
