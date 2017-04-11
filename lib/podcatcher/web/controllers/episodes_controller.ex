defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  def index(conn, %{"q" => search_term} = params) do
    page = Episodes.search_episodes(search_term, params)
    render conn, "search.html", %{page: page, search_term: search_term}
  end

  def index(conn, _params) do
    episodes = Episodes.latest_episodes(20)
    render conn, "index.html", %{episodes: episodes, page_title: "New releases"}
  end

  def episode(conn, %{"id" => id}) do
    episode = Episodes.get_episode!(id)
    page_title = "#{episode.podcast.title} - #{episode.title}"
    render conn, "episode.html", %{episode: episode, page_title: page_title}
  end
end
