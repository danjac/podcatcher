defmodule Podcatcher.Web.BookmarksController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Bookmarks
  alias Podcatcher.Episodes

  plug Podcatcher.Web.Plugs.RequireAuth

  def index(conn, %{"q" => ""} = params), do: list_bookmarks(conn, params)

  def index(conn, %{"q" => search_term} = params) do
    page = Bookmarks.search_bookmarks_for_user(conn.assigns[:user], search_term, params)
    episodes = Enum.map(page.entries, &(&1.episode))
    render conn, "index.html", episodes: episodes, page: page, search_term: search_term, page_title: "Bookmarks"
  end

  def index(conn, params), do: list_bookmarks(conn, params)

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

  defp list_bookmarks(conn, params) do
    page = Bookmarks.bookmarks_for_user(conn.assigns[:user], params)
    episodes = Enum.map(page.entries, &(&1.episode))
    render conn, "index.html", episodes: episodes, page: page, page_title: "Bookmarks"
  end

end

