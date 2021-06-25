defmodule RinariWeb.MovieController do
  use RinariWeb, :controller
  alias Rinari.Repo
  alias Rinari.Model.Movie
  import Ecto.Query

  def index(conn, _params) do
    render(conn, "index.json", links: page_list("movies"))
  end

  def show(conn, %{"imdb_id" => imdb_id}) do
    movie = Repo.one(from m in Movie, where: m.imdb_id == ^imdb_id)
    |> Repo.preload(:torrents)
    render(conn, "show.json", movie: movie)
  end
end
