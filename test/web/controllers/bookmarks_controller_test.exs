defmodule Podcatcher.Web.BookmarksControllerTest do
  use Podcatcher.Web.ConnCase

  alias Podcatcher.Bookmarks

  import Podcatcher.Fixtures

  test "GET /bookmarks/", %{conn: conn} do

    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    conn =
      conn
      |> assign(:user, user)
      |> get("/bookmarks/")

    assert html_response(conn, 200) =~ episode.title

  end

  test "GET /bookmarks/?q=", %{conn: conn} do

    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    conn =
      conn
      |> assign(:user, user)
      |> get("/bookmarks/", q: episode.title)

    assert html_response(conn, 200) =~ episode.title

  end


  test "POST /bookmarks/:id should add a bookmark", %{conn: conn} do
    user = fixture(:user)
    episode = fixture(:episode)

    conn =
      conn
      |> assign(:user, user)
      |> post("/api/bookmarks/#{episode.id}/")

    assert conn.status == 201

    [bookmark | _] = Bookmarks.bookmarks_for_user(user).entries
    assert bookmark.episode_id == episode.id

  end

  test "DELETE /bookmarks/:id should remove a bookmark", %{conn: conn} do
    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    conn =
      conn
      |> assign(:user, user)
      |> delete("/api/bookmarks/#{episode.id}/")

    assert conn.status == 200

    assert Bookmarks.bookmarks_for_user(user).total_entries == 0

  end

end

