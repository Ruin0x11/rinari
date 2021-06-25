defmodule Rinari.Jackett.Client do
  @moduledoc false

  defstruct api_key: nil, endpoint: nil, client: nil

  @type t :: %__MODULE__{api_key: binary, client: Tesla.Client.t}

  @doc """
  Returns a client instance you'll need to make api calls
  """
  @spec new(binary, binary) :: t
  def new(base_url, api_key) do
    opts = [
      Tesla.Middleware.JSON,
      {TeslaXML.Tesla.Middleware.XML, decode_content_types: ["application/rss+xml"]},
      {Tesla.Middleware.BaseUrl, "#{base_url}/api/v2.0"}
    ]
    %__MODULE__{
      api_key: api_key,
      client: Tesla.client(opts)
    }
  end
end
