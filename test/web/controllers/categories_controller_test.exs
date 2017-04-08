defmodule Podcatcher.Web.CategoriesControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  test "GET /browse/", %{conn: conn} do

    for _ <- 1..10, do: fixture(:category)
    conn = get conn, "/browse/"
    response = html_response(conn, 200)
  end


end
