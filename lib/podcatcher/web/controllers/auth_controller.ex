defmodule Podcatcher.Web.AuthController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Accounts
  alias Podcatcher.Mailer
  alias Podcatcher.Emails

  plug Podcatcher.Web.Plugs.RequireAuth when action in [:change_email, :update_email]

  @blacklisted_urls ["login", "signup", "recoverpass", "changepass"]

  def login(conn, %{"next" => next}) do
    conn
    |> put_session(:next, next)
    |> render("login.html")
  end

  def login(conn, _params), do: render(conn, "login.html")

  def handle_login(conn, %{"login" => %{"identifier" => identifier, "password" => password}}) do
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

  def handle_signup(conn, %{"user" => params}) do
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

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: podcasts_path(conn, :index))
  end

  def recover_password(conn, _params) do
    render conn, "recover_password.html"
  end

  def handle_recover_password(conn, %{"recover_password" => %{"identifier" => identifier}}) do
    case Accounts.get_user_by_name_or_email(identifier) do
      nil ->
        conn
        |> put_flash(:warning, "Sorry could not find your account")
        |> render("recover_password.html")
      user ->
        token = Accounts.generate_recovery_token!(user)
        Emails.reset_password_email(conn, user, token) |> Mailer.deliver_later
        redirect conn, to: auth_path(conn, :recover_password_done)
    end
  end

  def recover_password_done(conn, _params), do: render conn, "recover_password_done.html"

  def change_password(conn, %{"token" => token}) do
    user = Accounts.get_user_by_token!(token)
    changeset = Accounts.change_password(user)
    render conn, "change_password.html", token: token, changeset: changeset
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

  def update_password(conn, %{"user" => %{"token" => token} = params}) do
    user = Accounts.get_user_by_token!(token)
    do_update_password(conn, user, params, token)
  end

  def update_password(%Plug.Conn{assigns: %{user: user}} = conn, %{"user" => params}) do
    do_update_password(conn, user, params)
  end

  def update_password(conn, _params) do
    conn
    |> put_flash(:warning, "You must be logged in")
    |> redirect(to: auth_path(conn, :login))
  end

  defp do_update_password(conn, user, params, token \\ nil) do

    case Accounts.update_password(user, params) do

      {:ok, _} ->
        if conn.assigns[:user] do
          conn
          |> put_flash(:success, "Your password has been updated")
          |> redirect(to: default_user_path(conn))
        else
          conn
          |> put_flash(:success, "Your password has been updated, please sign in to continue")
          |> redirect(to: auth_path(conn, :login))
        end
      {:error, changeset} ->
        render conn, "change_password.html", token: token, changeset: changeset

    end

  end

  def change_email(conn, _params) do
    changeset = Accounts.change_email(conn.assigns[:user])
    render conn, "change_email.html", changeset: changeset
  end

  def update_email(conn, %{"user" => params}) do

    case Accounts.update_email(conn.assigns[:user], params) do
      {:ok, _} ->
      conn
      |> put_flash(:success, "Your email address has been updated")
      |> redirect(to: default_user_path(conn))
      {:error, changeset} ->
      render conn, "change_email.html", changeset: changeset
    end

  end

  defp redirect_after_login(conn) do
    next = get_session(conn, :next)
    cond do
      next && is_safe_url(conn, next) ->
        conn
        |> delete_session(:next)
        |> redirect(to: next)
      true -> redirect(conn, to: default_user_path(conn))
    end
  end

  defp is_safe_url(conn, url) do
    # only allow relative URLs, and ignore if same as current url
    String.starts_with?(url, "/") && !String.starts_with?(url, conn.request_path) && !is_blacklisted(url)
  end

  defp is_blacklisted(url) do
    Enum.any?(@blacklisted_urls, fn(blacklisted) -> String.contains?(url, blacklisted) end)
  end

  defp default_user_path(conn), do: subscriptions_path(conn, :index)

end

