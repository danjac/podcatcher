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
        |> redirect(episodes_path(conn, :index))
    end
  end

  def login(conn, _params), do: render(conn, "login.html")

  def signup(conn, _params), do: render(conn, "signup.html")

end

