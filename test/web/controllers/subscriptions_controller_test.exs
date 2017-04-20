defmodule Podcatcher.Web.SubscriptionsControllerTest do
  use Podcatcher.Web.ConnCase

  alias Podcatcher.Subscriptions

  import Podcatcher.Fixtures

  test "GET /feed/", %{conn: conn} do

    user = fixture(:user)
    podcast = fixture(:podcast)

    Subscriptions.create_subscription(user, podcast)

    conn =
      conn
      |> assign(:user, user)
      |> get("/feed/")

    assert html_response(conn, 200) =~ podcast.title

  end

  test "GET /feed/?q=", %{conn: conn} do

    user = fixture(:user)
    podcast = fixture(:podcast)

    Subscriptions.create_subscription(user, podcast)

    conn =
      conn
      |> assign(:user, user)
      |> get("/feed/", q: podcast.title)

    assert html_response(conn, 200) =~ podcast.title

  end


  test "POST /api/subscriptions/:id should subscribe to a podcast", %{conn: conn} do
    user = fixture(:user)
    podcast = fixture(:podcast)

    conn =
      conn
      |> assign(:user, user)
      |> post("/api/subscriptions/#{podcast.id}/")

    assert conn.status == 201

    [sub | _] = Subscriptions.subscriptions_for_user(user).entries
    assert sub.podcast_id == podcast.id

  end

  test "DELETE /api/subscriptions/:id should unsubcribe from a podcast", %{conn: conn} do
    user = fixture(:user)
    podcast = fixture(:podcast)

    Subscriptions.create_subscription(user, podcast)

    conn =
      conn
      |> assign(:user, user)
      |> delete("/api/subscriptions/#{podcast.id}/")

    assert conn.status == 200

    assert Subscriptions.subscriptions_for_user(user).total_entries == 0

  end

end

