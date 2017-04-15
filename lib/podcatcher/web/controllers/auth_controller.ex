defmodule Podcatcher.Web.AuthController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Accounts
  alias Podcatcher.Accounts.User

  def login(%Plug.Conn{method: "POST"} = conn, %{"login" => %{"identifier" => identifier, "password" => password}}) do
    case Accounts.authenticate(identifier, password) do
      {:error, _} ->
        conn
        |> put_flash(:warning, "Sorry, unable to log you in")
        |> render("login.html")
      user ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:success, "Welcome back, #{user.name}!")
        |> redirect_after_login
    end
  end

  def login(conn, _params), do: render(conn, "login.html")

  def signup(%Plug.Conn{method: "POST"} = conn, %{"user" => params}) do
    case Accounts.create_user(params) do
      {:ok, user} ->
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:success, "Welcome, #{user.name}")
      |> redirect_after_login
      {:error, changeset} ->
      render conn, "signup.html", changeset: changeset
    end
  end

  def signup(conn, _params) do
    changeset = Accounts.change_user()
    render conn, "signup.html", changeset: changeset
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: podcasts_path(conn, :index))
  end


  defp redirect_after_login(conn) do
    # TBD: check session for "next" and redirect there
    conn |> redirect(to: podcasts_path(conn, :index))
  end
end

