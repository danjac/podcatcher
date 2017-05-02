defmodule Podcatcher.Web.EpisodesControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  alias Podcatcher.Episodes
  alias Podcatcher.Subscriptions

  test "GET /latest/", %{conn: conn} do
    episode = fixture(:episode)
    conn = get conn, "/latest/"
    assert html_response(conn, 200) =~ episode.title
  end

  test "GET /latest/ when user logged in", %{conn: conn} do

    user = fixture(:user)
    episode = fixture(:episode)

    attrs = Map.merge(episode_attrs(), %{title: "other title"})

    {:ok, other_episode} = Episodes.create_episode(fixture(:podcast), attrs)

    Subscriptions.create_subscription(user, episode.podcast)

    conn =
      conn
      |> assign(:user, user)
      |> get("/latest/")

    response = html_response(conn, 200)

    assert response =~ episode.title
    refute response =~ other_episode.title

  end

  test "GET /latest/ when user logged in and t=all", %{conn: conn} do

    user = fixture(:user)
    episode = fixture(:episode)

    attrs = Map.merge(episode_attrs(), %{title: "other title"})

    {:ok, other_episode} = Episodes.create_episode(fixture(:podcast), attrs)

    Subscriptions.create_subscription(user, episode.podcast)

    conn =
      conn
      |> assign(:user, user)
      |> get("/latest/", %{"t" => "all"})

    response = html_response(conn, 200)

    assert response =~ episode.title
    assert response =~ other_episode.title

  end

  test "GET /episode/:id/:slug", %{conn: conn} do
    episode = fixture(:episode)
    conn = get conn, "/episode/#{episode.id}/some-slug"
    assert html_response(conn, 200) =~ episode.title
  end

end
