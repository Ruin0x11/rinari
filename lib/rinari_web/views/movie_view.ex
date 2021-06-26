defmodule RinariWeb.MovieView do
  use RinariWeb, :view

  def render("index.json", %{links: links}) do
    links
  end

  def render("show.json", %{movie: movie}) do
    %{data: render_one(movie, __MODULE__, "movie.json")}
  end

  def render("page.json", %{movies: movies}) do
    %{data: render_many(movies, __MODULE__, "movie.json", mode: :list)}
  end

  def render("movie.json", %{movie: movie, mode: mode}) do
    %{
      _id: movie.imdb_id,
      imdb_id: movie.imdb_id,
      title: movie.title,
      year: movie.release_date.year,
      synopsis: movie.synopsis,
      runtime: movie.runtime,
      released: movie.release_date,
      certification: movie.certification,
      torrents: render_one(movie.torrents, RinariWeb.TorrentView, "media_torrents.json", media: movie, mode: mode, as: :torrents),
      trailer: movie.trailer,
      genres: [],
      images: [],
      rating: []
    }
  end
end
