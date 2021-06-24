defmodule RinariWeb.PageController do
  use RinariWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
