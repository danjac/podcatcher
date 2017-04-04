defmodule Podcatcher.Web.PageControllerTest do
  use Podcatcher.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Podcast lover happiness"
  end
end
