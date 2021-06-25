defmodule Rinari.Repo.Migrations.CreateRelations do
  use Ecto.Migration

  @relations [
    {"anime", "torrent"},
    {"anime", "episode"},
    {"movie", "torrent"},
    {"show", "torrent"},
    {"episode", "torrent"},
  ]

  defp create_relation({left, right}) do
    left_plural = "#{left}s" |> String.to_atom
    right_plural = "#{right}s" |> String.to_atom
    table_id = "#{left_plural}_#{right_plural}" |> String.to_atom
    left_id = "#{left}_id" |> String.to_atom
    right_id = "#{right}_id" |> String.to_atom

    create table(table_id) do
      add left_id, references(left_plural)
      add right_id, references(right_plural)
      timestamps()
    end
  end

  def change do
    Enum.each(@relations, &create_relation/1)
  end
end
