defmodule Podcatcher.BookmarksTest do
  use Podcatcher.DataCase

  alias Podcatcher.Bookmarks

  import Podcatcher.Fixtures

  test "search_bookmarks_for_user/1 returns bookmarks for a user" do

    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    page = Bookmarks.search_bookmarks_for_user(user, episode.title)
    [bookmark | _] = page.entries
    assert bookmark.user_id == user.id
    assert bookmark.episode.id == episode.id

    page = Bookmarks.search_bookmarks_for_user(user, episode.podcast.title)
    [bookmark | _] = page.entries
    assert bookmark.user_id == user.id
    assert bookmark.episode.id == episode.id

    page = Bookmarks.search_bookmarks_for_user(user, "something else")
    assert page.total_entries == 0

  end


  test "bookmarks_for_user/1 returns bookmarks for a user" do
    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    page = Bookmarks.bookmarks_for_user(user)
    [bookmark | _] = page.entries
    assert bookmark.user_id == user.id
    assert bookmark.episode.id == episode.id

  end

  test "create_bookmark/2 creates a bookmark" do
    user = fixture(:user)
    episode = fixture(:episode)

    {:ok, bookmark} = Bookmarks.create_bookmark(user, episode)

    assert bookmark.user_id == user.id
    assert bookmark.episode_id == episode.id

  end

  test "delete_bookmark/2 deletes user bookmark" do

    user = fixture(:user)
    episode = fixture(:episode)

    Bookmarks.create_bookmark(user, episode)

    page = Bookmarks.bookmarks_for_user(user)
    assert page.total_entries == 1

    Bookmarks.delete_bookmark(user, episode)

    page = Bookmarks.bookmarks_for_user(user)
    assert page.total_entries == 0

  end

end
