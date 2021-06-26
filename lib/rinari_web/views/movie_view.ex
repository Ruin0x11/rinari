defmodule RinariWeb.MovieView do
  use RinariWeb, :view

  def render("index.json", %{links: links}) do
    links
  end

  def render("show.json", %{movie: movie}) do
    render_one(movie, __MODULE__, "movie.json")
  end

  def render("page.json", %{movies: movies}) do
     render_many(movies, __MODULE__, "movie.json", mode: :list)
  end

  def render("movie.json", %{movie: movie, mode: mode}) do
    %{
      _id: movie.imdb_id,
      imdb_id: movie.imdb_id,
      title: movie.title,
      year: movie.release_date.year |> Integer.to_string,
      synopsis: movie.synopsis,
      runtime: movie.runtime |> Integer.to_string,
      released: movie.release_date |> DateTime.to_unix,
      certification: movie.certification,
      torrents: render_one(movie.torrents, RinariWeb.TorrentView, "media_torrents.json", media: movie, mode: mode, as: :torrents),
      trailer: movie.trailer,
      genres: ["unknown"],
      images: movie.cover_image_set,
      rating: %{
        percentage: 100,
        watching: 0,
        votes: 1000,
        loved: 500,
        hated: 500,
      }
    }
  end
end
