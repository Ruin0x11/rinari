defmodule Rinari.Utils do
  alias Ecto.Changeset

  def typed_id_to_entity(type, id) when is_binary(type) do
    typed_id_to_entity(String.to_atom(type), id)
  end

  def typed_id_to_entity(type, id) do
    Rinari.Schemas.get(type)
    |> Rinari.Repo.get!(id)
  end

  def entity_to_typed_id(entity) do
    entity.__meta__.schema.__schema__(:source)
    |> String.to_atom
  end

  @image_base_url "http://image.tmdb.org/t/p/w500"

  defp get_images(tmdb) do
    [poster, backdrop] =
    [tmdb["poster_path"], tmdb["backdrop_path"]]
    |> Enum.map(fn url -> "#{@image_base_url}#{url}" end)

    %Rinari.Model.Embedded.CoverImageSet{poster: poster, fanart: backdrop, banner: poster}
  end

  def movie_title_to_entity(query) do
    client = Rinari.Tmdb.client
    with {:ok, %{"results" => results}} = client |> Tmdb.Search.movies(query),
         results <- results |> Enum.sort_by(fn m -> -m["popularity"] end) do
      movie = case Enum.find(results, fn m -> (m["title"] =~ ~r/^#{query}$/i) || (m["original_title"] =~ ~r/^#{query}$/i) end) do
                nil -> Enum.at(results, 0)
                m -> m |> IO.inspect
              end
      case movie do
        nil -> {:error, "No movie found. (query: #{query})"}
        x ->
          with {:ok, details} <- client |> Tmdb.Movies.find(x["id"], append_to_response: "images,release_dates,videos"),
               {:ok, movie} <- Rinari.Adapter.Movie.convert(details) do
            images = get_images(details)
            Changeset.change(movie)
            |> Changeset.put_embed(:cover_image_set, images)
            |> Rinari.Repo.insert()
          end
      end
    end
  end

  def index_torrents(media) do
    Rinari.Usagi.send_message(%{type: :torrent_index, media_type: entity_to_typed_id(media), id: media.id})
  end

  def search_movies(query) do
    Rinari.Usagi.send_message(%{type: :search, query: query})
  end
end
