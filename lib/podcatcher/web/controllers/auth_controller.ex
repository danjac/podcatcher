defmodule Podcatcher.Web.AuthController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Accounts

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

  def login(conn, %{"next" => next}) do
    conn
    |> put_session(:next, next)
    |> render("login.html")
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

  def signup(conn, %{"next" => next}) do
    changeset = Accounts.change_user()
    conn
    |> put_session(:next, next)
    |> render("signup.html", changeset: changeset)
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
    next = get_session(conn, :next)
    cond do
      next && is_safe_url(conn, next) ->
        conn
        |> delete_session(:next)
        |> redirect(to: next)
      true -> redirect(conn, to: podcasts_path(conn, :index))
    end
  end

  defp is_safe_url(conn, url) do
    # only allow relative URLs, and ignore if same as current url
    String.starts_with?(url, "/") && !String.starts_with?(url, conn.request_path)
  end
end

