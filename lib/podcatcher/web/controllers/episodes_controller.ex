defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  def index(conn, _params) do
    # just first page needed
    page = Episodes.latest_episodes(page: 1)
    render conn, "index.html", %{episodes: page.entries}
  end

  def episode(conn, %{"id" => id}) do
    episode = Episodes.get_episode!(id)
    render conn, "episode.html", %{episode: episode}
  end
end
