defmodule Rinari.Jackett do
  alias Rinari.Model

  def client do
    host = Application.get_env(:rinari, :jackett_host)
    port = Application.get_env(:rinari, :jackett_port)
    api_key = Application.get_env(:rinari, :jackett_api_key)
    base_url = "#{host}:#{port}"

    Rinari.Jackett.Client.new(base_url, api_key)
  end

  def configured_indexers(client) do
    with {:ok, indexers} <- client |> Rinari.Jackett.Api.Indexers.list do
      {:ok, Enum.filter(indexers, fn i -> i["configured"] end)}
    end
  end
end
