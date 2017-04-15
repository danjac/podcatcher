defmodule Podcatcher.Web.BookmarksController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Bookmarks
  alias Podcatcher.Episodes

  plug Podcatcher.Web.Plugs.RequireAuth

  def index(conn, _params) do
    page = Bookmarks.bookmarks_for_user(conn.assigns[:user])
    render conn, "index.html", page: page
  end

  def add_bookmark(conn, %{"id" => episode_id}) do
    episode = Episodes.get_episode!(episode_id)
    Bookmarks.create_bookmark(conn.assigns[:user], episode)
    send_resp(conn, :created, "Bookmark created")
  end

  def delete_bookmark(conn, %{"id" => episode_id}) do
    episode = Episodes.get_episode!(episode_id)
    Bookmarks.delete_bookmark(conn.assigns[:user], episode)
    send_resp(conn, :ok, "Bookmark deleted")
  end

end

