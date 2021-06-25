defmodule Rinari.Tmdb do
  def client do
    Application.fetch_env!(:rinari, :tmdb_api_key)
    |> Tmdb.Client.new
  end
end
