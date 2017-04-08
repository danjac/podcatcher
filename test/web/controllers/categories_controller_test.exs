defmodule Podcatcher.Web.CategoriesControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures
  alias Podcatcher.Podcasts

  test "GET /browse/", %{conn: conn} do

    for _ <- 1..10, do: fixture(:category)
    conn = get conn, "/browse/"
    response = html_response(conn, 200)
  end

  test "GET /browse/:id/", %{conn: conn} do
    category = fixture(:category)
    podcast = fixture(:podcast)

    podcast
    |> Podcasts.update_podcast(%{}, [category])

    conn = get conn, "/browse/#{category.id}/"
    response = html_response(conn, 200)
    assert response =~ category.name
    assert response =~ podcast.title
  end
end
