defmodule RinariWeb.ControllerHelpers do
  alias Rinari.Repo
  import Ecto.Query

  @page_size 50

  def page_list(relation) do
    count = Repo.one(from e in relation, select: count(e.id))
    page_count = ceil(count / @page_size)
    Enum.map(1..page_count, fn i -> "#{relation}/#{i}" end)
  end

  def to_page_request(conn) do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.query_params

    genre = case (params["genre"] || "all") |> String.downcase do
              "all" -> nil
              x -> x
            end

    %Rinari.Request.PageRequest{
      genre: genre,
      keywords: params["keywords"],
      sort: params["sort"],
      order: params["order"]
    }
  end

  def make_page_request(%Rinari.Request.PageRequest{} = page_request, schema, page) do
    offset = (page - 1) * @page_size
    limit = @page_size
    Rinari.Elastic.Client.search(page_request, schema, offset, limit)
  end
end
