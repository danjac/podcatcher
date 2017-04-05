defmodule Podcatcher.Web.PodcastsControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  test "GET /podcast/:id/", %{conn: conn} do

    podcast = fixture(:podcast)
    episode = fixture(:episode, podcast)
    conn = get conn, "/podcast/#{podcast.id}/"
    response = html_response(conn, 200)

    assert response =~ podcast.title
    assert response =~ episode.title
  end


end
