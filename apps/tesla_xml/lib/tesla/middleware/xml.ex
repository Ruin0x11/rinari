defmodule TeslaXML.Tesla.Middleware.XML do
  @moduledoc """
  Encode requests and decode responses as XML.
  This middleware requires [jason](https://hex.pm/packages/saxy) as dependency.
  ```
  mix deps.clean tesla
  mix deps.compile tesla
  ```
  ## Example usage
  ```
  defmodule MyClient do
    use Tesla
    plug TeslaXML.Tesla.Middleware.XML # use saxy engine
  end
  ```
  ## Options
  - `:decode` - decoding function
  - `:encode` - encoding function
  - `:encode_content_type` - content-type to be used in request header
  - `:decode_content_types` - list of additional decodable content-types
  """
  @behaviour Tesla.Middleware

  alias TeslaXML.XML.{Decoder, Encoder}

  # NOTE: text/javascript added to support Facebook Graph API.
  #       see https://github.com/teamon/tesla/pull/13
  @default_content_types ["text/xml"]
  @default_encode_content_type "text/xml"

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- encode(env, opts),
         {:ok, env} <- Tesla.run(env, next) do
      decode(env, opts)
    end
  end

  @doc """
  Encode request body as XML.
  It is used by `TeslaXML.Tesla.Middleware.EncodeXML`.
  """
  def encode(env, opts) do
    with true <- encodable?(env),
         {:ok, body} <- encode_body(env.body, opts) do
      {:ok,
       env
       |> Tesla.put_body(body)
       |> Tesla.put_headers([{"content-type", encode_content_type(opts)}])}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  defp encode_body(body, opts) when is_function(body), do: {:ok, encode_stream(body, opts)}
  defp encode_body(body, opts), do: process(body, :encode, opts)

  defp encode_content_type(opts),
    do: Keyword.get(opts, :encode_content_type, @default_encode_content_type)

  defp encode_stream(body, opts) do
    Stream.map(body, fn item ->
      {:ok, body} = encode_body(item, opts)
      body
    end)
  end

  defp encodable?(_), do: false

  @doc """
  Decode response body as XML.
  It is used by `TeslaXML.Tesla.Middleware.DecodeXML`.
  """
  def decode(env, opts) do
    with true <- decodable?(env, opts),
         {:ok, body} <- decode_body(env.body, opts) do
      {:ok, %{env | body: body}}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  defp decode_body(body, opts), do: process(body, :decode, opts)

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body) && env.body != "") || (is_list(env.body) && env.body != [])
  end

  defp decodable_content_type?(env, opts) do
    case Tesla.get_header(env, "content-type") do
      nil -> false
      content_type -> Enum.any?(content_types(opts), &String.starts_with?(content_type, &1))
    end
  end

  defp content_types(opts),
    do: @default_content_types ++ Keyword.get(opts, :decode_content_types, [])

  defp process(data, op, opts) do
    case do_process(data, op, opts) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {__MODULE__, op, reason}}
      {:error, reason, _pos} -> {:error, {__MODULE__, op, reason}}
    end
  rescue
    ex in Protocol.UndefinedError ->
      {:error, {__MODULE__, op, ex}}
  end

  defp do_process(data, op, opts) do
    # :encode/:decode
    try do
      if fun = opts[op] do
        fun.(data)
      else
        {engine, fun} = get_encoder_fun(op)

        {:ok, apply(engine, fun, [data])}
      end
    rescue
      e ->
        {:error, e}
    end
  end

  defp get_encoder_fun(:encode), do: {Encoder, :encode!}
  defp get_encoder_fun(:decode), do: {Decoder, :decode!}
end
