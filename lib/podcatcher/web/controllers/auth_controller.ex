defmodule Podcatcher.Web.AuthController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Accounts

  @blacklisted_urls ["login", "signup"]

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

  def recover_password(conn, _params) do
    render conn, "recover_password.html", user_not_found: false
  end

  def recover_password(conn, %{"identifier" => identifier}) do
    case Accounts.get_user_by_name_or_email(identifier) do
      {:ok, user} ->
        token = Accounts.generate_recovery_token(user)
        IO.puts token
        # send token...
        redirect conn, to: auth_path(:recover_password_done)
      {:error, _} ->
        render conn, "recover_password.html", user_not_found: true
    end
  end

  def recover_password_done(conn, _params), do: render conn, "recover_password_done.html"

  def change_password(conn, %{"token" => token, "user" => params}) do
    user = Accounts.get_user_by_token!(token)
    do_change_password(conn, user, params)
  end

  def change_password(%Plug.Conn{assigns: %{user: user}} = conn, %{"user" => params}) do
    do_change_password(conn, user, params)
  end

  def change_password(conn, %{"token" => token}) do
    user = Accounts.get_user_by_token!(token)
    changeset = Accounts.change_password(user)
    render conn, "change_password.html", changeset: changeset
  end

  def change_password(%Plug.Conn{assigns: %{user: user}} = conn, _params) do
    changeset = Accounts.change_password(user)
    render conn, "change_password.html", changeset: changeset
  end

  def change_password(conn, _params) do
    conn
    |> put_flash(:warning, "You must be logged in")
    |> redirect(to: auth_path(conn, :login))
  end

  defp do_change_password(conn, user, params) do

    case Accounts.change_password(user, params) |> Accounts.update_user do

      {:ok, _} ->
        if conn.assigns[:user] do
          conn
          |> put_flash(:success, "Your password has been updated")
          |> redirect(to: subscriptions_path(conn, :index))
        else
          conn
          |> put_flash(:success, "Your password has been updated, please sign in to continue")
          |> redirect(to: auth_path(conn, :login))
        end
      {:error, changeset} ->
        render conn, "change_password.html", changeset: changeset

    end

  end

  defp redirect_after_login(conn) do
    next = get_session(conn, :next)
    cond do
      next && is_safe_url(conn, next) ->
        conn
        |> delete_session(:next)
        |> redirect(to: next)
      true -> redirect(conn, to: subscriptions_path(conn, :index))
    end
  end

  defp is_safe_url(conn, url) do
    # only allow relative URLs, and ignore if same as current url
    String.starts_with?(url, "/") && !String.starts_with?(url, conn.request_path) && !is_blacklisted(url)
  end

  defp is_blacklisted(url) do
    Enum.any?(@blacklisted_urls, fn(blacklisted) -> String.contains?(url, blacklisted) end)
  end

end

