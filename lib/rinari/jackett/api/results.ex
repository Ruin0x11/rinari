defmodule Rinari.Jackett.Api.Results do
  import Rinari.Jackett
  alias Rinari.Jackett.Client

  def caps(%Client{api_key: api_key, client: client}, indexer) do
    case client |> get!("/indexers/#{indexer}/results/torznab/", query: [{:apikey, api_key}, {:t, "caps"}]) do
      {:ok, resp} -> {:ok, resp.body}
      {:error, err} -> {:error, err}
    end
  end

  defp parse_search(body) do
    body["rss"]["channel"]
  end

  def search(%Client{api_key: api_key, client: client}, indexer, query) do
    case client |> get!("/indexers/#{indexer}/results/torznab/", query: [{:apikey, api_key}, {:q, query}]) do
      {:ok, resp} -> {:ok, parse_search(resp.body)}
      {:error, err} -> {:error, err}
    end
  end

  def search_by_imdb(%Client{api_key: api_key, client: client}, indexer, imdb_id) do
    case client |> get!("/indexers/#{indexer}/results/torznab/", query: [{:apikey, api_key}, {:imdbid, imdb_id}]) do
      {:ok, resp} -> {:ok, parse_search(resp.body)}
      {:error, err} -> {:error, err}
    end
  end
end

# i |> Enum.filter(fn z -> z["configured"] end) |> Enum.map(fn z -> {:ok, a} = Rinari.Jackett.Api.Results.caps(Rinari.Jackett.client, z["id"]); {z["id"], a} end) |> Enum.filter(fn {id, a} -> a |> IO.inspect |> get_in(["caps", "searching", "movie-search", "supportedParams"]) |> String.contains?("imdb") end)
