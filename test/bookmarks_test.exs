defmodule Podcatcher.BookmarksTest do
  use Podcatcher.DataCase

  alias Podcatcher.Bookmarks
  alias Podcatcher.Bookmarks.Bookmark

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:bookmark, attrs \\ @create_attrs) do
    {:ok, bookmark} = Bookmarks.create_bookmark(attrs)
    bookmark
  end

  test "list_bookmarks/1 returns all bookmarks" do
    bookmark = fixture(:bookmark)
    assert Bookmarks.list_bookmarks() == [bookmark]
  end

  test "get_bookmark! returns the bookmark with given id" do
    bookmark = fixture(:bookmark)
    assert Bookmarks.get_bookmark!(bookmark.id) == bookmark
  end

  test "create_bookmark/1 with valid data creates a bookmark" do
    assert {:ok, %Bookmark{} = bookmark} = Bookmarks.create_bookmark(@create_attrs)
  end

  test "create_bookmark/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Bookmarks.create_bookmark(@invalid_attrs)
  end

  test "update_bookmark/2 with valid data updates the bookmark" do
    bookmark = fixture(:bookmark)
    assert {:ok, bookmark} = Bookmarks.update_bookmark(bookmark, @update_attrs)
    assert %Bookmark{} = bookmark
  end

  test "update_bookmark/2 with invalid data returns error changeset" do
    bookmark = fixture(:bookmark)
    assert {:error, %Ecto.Changeset{}} = Bookmarks.update_bookmark(bookmark, @invalid_attrs)
    assert bookmark == Bookmarks.get_bookmark!(bookmark.id)
  end

  test "delete_bookmark/1 deletes the bookmark" do
    bookmark = fixture(:bookmark)
    assert {:ok, %Bookmark{}} = Bookmarks.delete_bookmark(bookmark)
    assert_raise Ecto.NoResultsError, fn -> Bookmarks.get_bookmark!(bookmark.id) end
  end

  test "change_bookmark/1 returns a bookmark changeset" do
    bookmark = fixture(:bookmark)
    assert %Ecto.Changeset{} = Bookmarks.change_bookmark(bookmark)
  end
end
