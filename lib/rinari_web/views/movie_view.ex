defmodule RinariWeb.MovieView do
  use RinariWeb, :view

  def render("index.json", %{links: links}) do
    links
  end

  def render("show.json", %{movie: movie}) do
    %{data: render_one(movie, MovieView, "movie.json")}
  end

  def render("movie.json", %{movie: movie}) do
    %{
      _id: movie.imdb_id,
      imdb_id: movie.imdb_id,
      title: movie.title,
      year: movie.release_date.year,
      synopsis: movie.synopsis,
      runtime: movie.runtime,
      released: movie.release_date,
      certification: movie.certification,
      torrents: render_many(movie.torrents, RinariWeb.TorrentView, "torrent.json", media: movie, mode: "item"),
      trailer: movie.trailer,
      genres: [],
      images: [],
      rating: []
    }
  end
end
