defmodule Podcatcher.Web.PodcastsControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  test "GET /discover", %{conn: conn} do

    podcast = fixture(:podcast)

    conn = get conn, "/discover"
    response = html_response(conn, 200)

    assert response =~ podcast.title

  end

  test "GET /discover with search", %{conn: conn} do

    podcast = fixture(:podcast)

    conn = get conn, "/discover", %{"q" => podcast.title}
    response = html_response(conn, 200)

    assert response =~ podcast.title

  end

  test "GET /discover with random order", %{conn: conn} do

    podcast = fixture(:podcast)

    conn = get conn, "/discover", %{"r" => "1"}
    response = html_response(conn, 200)

    assert response =~ podcast.title

  end

  test "GET /podcast/:id/", %{conn: conn} do

    podcast = fixture(:podcast)
    episode = fixture(:episode, podcast)
    conn = get conn, "/podcast/#{podcast.id}/#{podcast.slug}"
    response = html_response(conn, 200)

    assert response =~ podcast.title
    assert response =~ episode.title
  end


end
