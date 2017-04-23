defmodule Podcatcher.Web.Plugs.RequireAdmin do

  import Plug.Conn

  def init(_) do
  end

  def call(conn, _params) do
    if is_nil(conn.assigns[:user]) || !conn.assigns[:user].is_admin do
      conn
      |> put_status(401)
      |> halt()
    else
      conn
    end
  end

end

