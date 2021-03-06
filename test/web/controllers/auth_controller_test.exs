defmodule Podcatcher.Web.AuthControllerTest do
  use Podcatcher.Web.ConnCase
  use Bamboo.Test

  import Podcatcher.Fixtures

  alias Podcatcher.Repo
  alias Podcatcher.Accounts
  alias Podcatcher.Accounts.User
  alias Podcatcher.Emails

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
    assert redirected_to(conn) =~ "/feed"

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
    assert redirected_to(conn) =~ "/browse"

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
    assert redirected_to(conn) =~ "/feed"

  end

  test "POST /login/ if next url in blacklist" do

    user = fixture(:user)

    params = %{
      "login" => %{
        "identifier" => user.email,
        "password" => "testpass",
      }
    }

    conn =
      session_conn()
      |> put_session(:next, "/signup/")
      |> post("/login/", params)

    assert conn.status == 302
    assert get_session(conn, :user_id) == user.id
    assert redirected_to(conn) =~ "/feed"

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

    assert redirected_to(conn) =~ "/feed"

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
    assert redirected_to(conn) =~ "/browse"

  end

  test "GET /logout/", %{conn: conn} do

    conn = get conn, "/logout/"
    assert redirected_to(conn) =~ "/discover"
  end

  test "GET /recoverpass/", %{conn: conn} do
    conn = get conn, "/recoverpass/"
    html_response(conn, 200)
  end

  test "POST /recoverpass/ if invalid identifier", %{conn: conn} do
    params = %{
      "recover_password" => %{
        "identifier" => "tester"
      }
    }

    conn = post conn, "/recoverpass/", params
    assert conn.status == 200

  end

  test "POST /recoverpass/ if valid identifier", %{conn: conn} do

    user = fixture(:user)
    params = %{
      "recover_password" => %{
        "identifier" => user.email
      }
    }

    conn = post conn, "/recoverpass/", params

    assert redirected_to(conn) =~ "/recoverpassdone"

    token = Accounts.get_user!(user.id).recovery_token

    assert_delivered_email Emails.reset_password_email(conn, user, token)

  end

  test "GET /changepass if no token or not logged in", %{conn: conn} do
    conn = get conn, "/changepass/"
    assert redirected_to(conn) =~ "/login"
  end

  test "GET /changepass if valid token and not logged in", %{conn: conn} do
    user = fixture(:user)
    token = Accounts.generate_recovery_token!(user)
    conn = get conn, "/changepass/", %{"token" => token}
    assert conn.status == 200
  end

  test "GET /changepass if  logged in", %{conn: conn} do
    user = fixture(:user)

    conn =
      conn
      |> assign(:user, user)
      |> get("/changepass/")

    assert conn.status == 200
  end

  test "PUT /changepass if no token or not logged in", %{conn: conn} do

    params = %{
      "user" => %{
        "password" => "testpass",
        "password_confirmation" => "testpass",
      }
    }

    conn = put conn, "/changepass/", params
    assert redirected_to(conn) =~ "/login"

  end

  test "PUT /changepass if valid token and not logged in", %{conn: conn} do
    user = fixture(:user)
    token = Accounts.generate_recovery_token!(user)

    params = %{
      "user" => %{
        "token" => token,
        "password" => "testpass_new",
        "password_confirmation" => "testpass_new",
      }
    }

    conn = put conn, "/changepass/", params
    assert redirected_to(conn) =~ "/login"

    user = Accounts.get_user!(user.id)
    assert Accounts.check_password("testpass_new", user.password)

  end

  test "PUT /changepass if logged in", %{conn: conn} do
    user = fixture(:user)

    params = %{
      "user" => %{
        "password" => "testpass_new",
        "password_confirmation" => "testpass_new",
      }
    }

    conn =
      conn
      |> assign(:user, user)
      |> put("/changepass/", params)

    assert redirected_to(conn) =~ "/feed"

    user = Accounts.get_user!(user.id)
    assert Accounts.check_password("testpass_new", user.password)

  end

  test "GET /changemail", %{conn: conn}  do
    user = fixture(:user)

    conn =
      conn
      |> assign(:user, user)
      |> get("/changemail")

    assert conn.status == 200

  end

  test "PUT /changemail", %{conn: conn}  do
    user = fixture(:user)

    params = %{
      "user" => %{
        "email" => "new@gmail.com"
      }
    }

    conn =
      conn
      |> assign(:user, user)
      |> put("/changemail", params)

    assert redirected_to(conn) =~ "/feed"

    user = Accounts.get_user!(user.id)
    assert user.email == "new@gmail.com"

  end

end

