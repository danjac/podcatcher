defmodule Podcatcher.Web.EpisodesControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  test "GET /latest/", %{conn: conn} do
    episode = fixture(:episode)
    conn = get conn, "/latest/"
    assert html_response(conn, 200) =~ episode.title
  end

  test "GET /episode/:id/", %{conn: conn} do
    episode = fixture(:episode)
    conn = get conn, "/episode/#{episode.id}/"
    assert html_response(conn, 200) =~ episode.title
  end


end
