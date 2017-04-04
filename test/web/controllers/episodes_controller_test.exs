defmodule Podcatcher.Web.EpisodesControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  test "GET /", %{conn: conn} do
    episode = fixture(:episode)
    conn = get conn, "/latest/"
    assert html_response(conn, 200) =~ episode.title
  end
end
