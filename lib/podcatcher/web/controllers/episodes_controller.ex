defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  def index(conn, _params) do
    episodes = Episodes.latest_episodes(20)
    render conn, "index.html", %{episodes: episodes}
  end

  def episode(conn, %{"id" => id}) do
    episode = Episodes.get_episode!(id)
    render conn, "episode.html", %{episode: episode}
  end
end
