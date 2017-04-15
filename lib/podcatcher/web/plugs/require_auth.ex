defmodule Podcatcher.Web.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  import Podcatcher.Web.Router.Helpers, only: [auth_path: 3]

  def init(_) do
  end

  def call(conn, _params) do
    if is_nil(conn.assigns[:user]) do
      handle_unauthenticated(conn)
    else
      conn
    end
  end

  defp handle_unauthenticated(conn) do
    if is_xhr?(conn) do
      conn
      |> put_status(:unauthenticated)
      |> halt()
    else
      conn
      |> put_flash(:error, "You must be logged in")
      |> redirect(to: auth_path(conn, :login, next: conn.request_path))
      |> halt()
    end
  end

  defp is_xhr?(conn), do: "XMLHttpRequest" in get_req_header(conn, "x-requested-with")

end

