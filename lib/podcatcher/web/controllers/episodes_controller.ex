defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  def index(conn, params) do
    page = Episodes.latest_episodes(params)
    render conn, "index.html", %{page: page}
  end
end
