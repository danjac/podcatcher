defmodule Podcatcher.Web.AuthControllerTest do
  use Podcatcher.Web.ConnCase

  import Podcatcher.Fixtures

  alias Podcatcher.Repo
  alias Podcatcher.Accounts.User

  test "GET /login/", %{conn: conn} do
    conn = get conn, "/login/"
    refute get_session(conn, :next) == "/latest"
    html_response(conn, 200)
  end

  test "GET /login/?next=/latest", %{conn: conn} do
    conn = get conn, "/login/?next=/latest"
    assert get_session(conn, :next) == "/latest"
    html_response(conn, 200)
  end

  test "POST /login/ if unsuccessful", %{conn: conn} do
    params = %{
      "login" => %{
        "identifier" => "something@gmail.com",
        "password" => "testpass",
      }
    }

    conn = post conn, "/login/", params
    assert conn.status == 200
    assert is_nil(get_session(conn, :user_id))

  end

  test "POST /login/ if successful", %{conn: conn} do
    user = fixture(:user)

    params = %{
      "login" => %{
        "identifier" => user.email,
        "password" => "testpass",
      }
    }

    conn = post conn, "/login/", params
    assert conn.status == 302
    assert get_session(conn, :user_id) == user.id
    assert Map.new(conn.resp_headers)["location"] == "/discover"

  end

  test "POST /login/ if next url in session" do
    user = fixture(:user)

    params = %{
      "login" => %{
        "identifier" => user.email,
        "password" => "testpass",
      }
    }

    conn =
      session_conn()
      |> put_session(:next, "/browse")
      |> post("/login/", params)

    assert conn.status == 302
    assert get_session(conn, :user_id) == user.id
    assert Map.new(conn.resp_headers)["location"] == "/browse"

  end

  test "POST /login/ if next url in session is dangerous" do

    user = fixture(:user)

    params = %{
      "login" => %{
        "identifier" => user.email,
        "password" => "testpass",
      }
    }

    conn =
      session_conn()
      |> put_session(:next, "http://my-scammy-site.com")
      |> post("/login/", params)

    assert conn.status == 302
    assert get_session(conn, :user_id) == user.id
    assert Map.new(conn.resp_headers)["location"] == "/discover"

  end


  test "GET /signup/", %{conn: conn} do
    conn = get conn, "/signup/"
    refute get_session(conn, :next) == "/latest"
    html_response(conn, 200)
  end

  test "GET /signup/?next=/latest", %{conn: conn} do
    conn = get conn, "/signup/?next=/latest"
    assert get_session(conn, :next) == "/latest"
    html_response(conn, 200)
  end

  test "POST /signup/ if successful", %{conn: conn} do

    params = %{
      "user" => %{
        "name" => "tester",
        "email" => "tester@gmail.com",
        "password" => "testpass",
        "password_confirmation" => "testpass",
      }
    }

    conn = post conn, "/signup/", params
    assert conn.status == 302

    user = Repo.one!(User)

    assert get_session(conn, :user_id) == user.id
    assert Map.new(conn.resp_headers)["location"] == "/discover"

  end

  test "POST /signup/ if next url in session" do

    params = %{
      "user" => %{
        "name" => "tester",
        "email" => "tester@gmail.com",
        "password" => "testpass",
        "password_confirmation" => "testpass",
      }
    }

    conn =
      session_conn()
      |> put_session(:next, "/browse")
      |> post("/signup/", params)

    user = Repo.one!(User)

    assert get_session(conn, :user_id) == user.id
    assert Map.new(conn.resp_headers)["location"] == "/browse"

  end

  test "GET /logout/", %{conn: conn} do

    conn = get conn, "/logout/"
    assert conn.status == 302
    assert Map.new(conn.resp_headers)["location"] == "/discover"

  end

end

