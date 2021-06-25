defmodule RinariWeb.ControllerHelpers do
  alias Rinari.Repo
  import Ecto.Query

  @page_size 50

  def page_list(relation) do
    count = Repo.one(from e in relation, select: count(e.id))
    page_count = ceil(count / @page_size)
    Enum.map(1..page_count, fn i -> "#{relation}/#{i}" end)
  end
end
