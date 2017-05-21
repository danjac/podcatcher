defmodule Podcatcher.Web.PageControllerTest do
  use Podcatcher.Web.ConnCase

  test "GET / if user logs in redirects to their feed", %{conn: conn} do

    conn = conn
      |> assign(:user, %Podcatcher.Accounts.User{})
      |> get("/")
    assert redirected_to(conn) =~ "/feed"
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Get started"
  end
end
