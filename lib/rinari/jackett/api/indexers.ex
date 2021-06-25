defmodule Rinari.Jackett.Api.Indexers do
  import Rinari.Jackett
  alias Rinari.Jackett.Client

  def list(%Client{client: client}) do
    case client |> get_admin("/indexers/") do
      {:ok, resp} -> {:ok, resp.body}
      {:error, err} -> {:error, err}
    end
  end

  def get(%Client{client: client}, indexer) do
    case client |> get_admin("/indexers/#{indexer}/Config") do
      {:ok, resp} -> {:ok, resp.body}
      {:error, err} -> {:error, err}
    end
  end
end
