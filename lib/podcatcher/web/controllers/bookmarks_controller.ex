defmodule Podcatcher.Web.BookmarksController do
  use Podcatcher.Web, :controller

  plug Podcatcher.Web.Plugs.RequireAuth

  def index(conn, _params) do
    render conn, "index.html"
  end

end

