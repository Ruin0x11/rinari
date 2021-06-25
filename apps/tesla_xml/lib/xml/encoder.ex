defprotocol TeslaXML.XML.Encoder do
  @moduledoc """
  Protocol for building XML content. A proxy to Saxy.Builder protocol
  """
  @doc """
  Encode to XML string. Proxy to Saxy.encode!
  """
  @spec encode!(content :: term()) :: binary
  def encode!(content)

  @doc """
  Sanitize value
  """
  @spec sanitize(content :: term()) :: any
  def sanitize(content)
end

defimpl TeslaXML.XML.Encoder, for: Any do
  defmacro __deriving__(module, struct, options) do
    name_option =
      Keyword.get(
        options,
        :name,
        module
        |> Module.split()
        |> List.last()
      )

    attributes_option = Keyword.get(options, :attributes, [])
    children_option = Keyword.get(options, :children, [])

    allowed_children =
      struct
      |> Map.keys()
      |> Enum.filter(&(&1 != :__struct__))

    children_names =
      allowed_children
      |> Enum.reduce([], &Keyword.put(&2, &1, &1 |> Inflex.camelize() |> String.to_atom()))
      |> Keyword.merge(Keyword.get(options, :names, []))

    quote location: :keep do
      defimpl Saxy.Builder, for: unquote(module) do
        @name_option unquote(name_option)
        @attributes_option unquote(attributes_option)
        @children_option unquote(children_option)
        @allowed_children unquote(allowed_children)
        @children_names unquote(children_names)

        def build(struct) do
          import Saxy.XML
          alias TeslaXML.XML.Encoder

          build_children = fn k, struct ->
            if Map.has_key?(struct, k) do
              v = Map.get(struct, k, nil)

              @children_names
              |> Keyword.get(k)
              |> element([], Encoder.sanitize(v))
            else
              Map.get(struct, k, nil)
            end
          end

          name =
            case @name_option do
              {:attr, n} -> Map.get(struct, String.to_atom(n))
              n -> n
            end

          attributes =
            struct
            |> Map.take(@attributes_option)
            |> Enum.to_list()

          children =
            @children_option
            |> Enum.map(fn el ->
              if el in @allowed_children do
                build_children.(el, struct)
              else
                raise ArgumentError,
                  message:
                    "The children #{el} is invalid. Allowed filters are: " <>
                      "#{Enum.join(@allowed_children, ", ")}"
              end
            end)

          element(name, attributes, children)
        end
      end
    end
  end

  def encode!(data), do: Saxy.encode!(data)

  def sanitize(value), do: value
end

defimpl TeslaXML.XML.Encoder,
  for: [
    Tuple,
    BitString,
    Atom,
    Integer,
    Float,
    NaiveDateTime,
    DateTime,
    Date,
    Time,
    List
  ] do
  def encode!(data), do: Saxy.encode!(data)

  def sanitize(v) when is_tuple(v), do: v

  def sanitize(v) when is_list(v),
    do: Enum.map(v, &sanitize/1)

  def sanitize(v) when is_atom(v),
    do: sanitize(Atom.to_string(v))

  def sanitize(v) when is_float(v),
    do: sanitize(Float.to_string(v))

  def sanitize(v) when is_integer(v),
    do: sanitize(Integer.to_string(v))

  def sanitize(%NaiveDateTime{} = v),
    do: Timex.format!(v, "{0D}.{0M}.{YYYY} {0h24}:{0m}:{0s}")

  def sanitize(v),
    do: {
      if is_nil(Regex.run(~r/^[0-9A-Za-z]+$/, v)) do
        :cdata
      else
        :characters
      end,
      v
    }
end
