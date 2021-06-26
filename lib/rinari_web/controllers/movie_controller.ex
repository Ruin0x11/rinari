defmodule RinariWeb.MovieController do
  use RinariWeb, :controller
  alias Rinari.Repo
  alias Rinari.Model.{Movie, Torrent}
  import Ecto.Query

  def index(conn, _params) do
    render(conn, "index.json", links: page_list("movies"))
  end

  def show(conn, %{"imdb_id" => imdb_id}) do
    movie = Repo.one(from m in Movie, where: m.imdb_id == ^imdb_id)
    |> Repo.preload(:torrents)
    render(conn, "show.json", movie: movie, mode: :item)
  end

  def page(conn, %{"page" => page}) do
    page_request = conn |> to_page_request()
    page = case Integer.parse(page) do
             {p, _} -> p
             _ -> 1
           end

    {:ok, %{"hits" => %{"hits" => hits}}} = make_page_request(page_request, Movie, page)

    ids = Enum.map(hits, fn hit -> hit["_source"]["id"] end)
    movies = Repo.all(
      from m in Movie,
      where: m.id in ^ids,
      preload: [
        torrents:
        ^from(
          t in Torrent,
          order_by: [asc: t.seeders]
        )
      ]
    )
    render(conn, "page.json", movies: movies)
  end
end
