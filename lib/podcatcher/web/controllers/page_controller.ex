defmodule Podcatcher.Web.PageController do
  use Podcatcher.Web, :controller

  def index(%Plug.Conn{assigns: %{user: _}} = conn, _params) do
    redirect conn, to: subscriptions_path(conn, :index)
  end

  def index(conn, _params) do
    conn
    |> put_layout(false)
    |> render("index.html")
  end
end
