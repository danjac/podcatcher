defmodule Podcatcher.Web.PageController do
  use Podcatcher.Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout(false)
    |> render("index.html")
  end
end
