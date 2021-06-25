defmodule Rinari.Jackett do
  alias Rinari.Jackett.Client

  @moduledoc """
  Provides multiple functions to make http requests using either of the methods
  GET, POST, PUT or DELETE.
  """

  def client do
    host = Application.get_env(:rinari, :jackett_host)
    port = Application.get_env(:rinari, :jackett_port)
    api_key = Application.get_env(:rinari, :jackett_api_key)
    base_url = "#{host}:#{port}"

    Rinari.Jackett.Client.new(base_url, api_key)
  end

  @spec get_admin(Client.t, binary, [{atom, binary}] | []) :: Tesla.Env.result
  def get_admin(client, path, params \\ []) do
    case get!(client, path, params) do
      {:ok, %Tesla.Env{status: 302} = env} ->
        {:ok, auth_env} = Tesla.get(Tesla.client([]), Tesla.get_header(env, "location"))
        cookie = Tesla.get_header(auth_env, "set-cookie")
        get!(client, path, Keyword.put(params, :headers, Keyword.merge(Keyword.get(params, :headers) || [], [cookie: cookie])))
      x -> x
    end
  end

  def get!(client, path, opts \\ []), do: Tesla.get(client, path, opts)
end
