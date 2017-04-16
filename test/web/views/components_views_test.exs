defmodule Podcatcher.Web.ComponentsViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.ComponentsView

  alias Podcatcher.Episodes.Episode

  test "bookmarked?/2 if no bookmarks" do

    refute bookmarked?(%Plug.Conn{}, %Episode{id: 1})

  end

  test "bookmarked?2 if bookmarked" do

    conn =
      %Plug.Conn{}
      |> assign(:bookmarks, [1])

    assert bookmarked?(conn, %Episode{id: 1})

  end

  test "bookmarked?2 if not bookmarked" do

    conn =
      %Plug.Conn{}
      |> assign(:bookmarks, [])

    refute bookmarked?(conn, %Episode{id: 1})

  end

end

