defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
