defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  @num_latest_episodes 20

  def index(conn, _params) do
    episodes = case conn.assigns[:user] do
      nil -> Episodes.latest_episodes(@num_latest_episodes)
      user -> Episodes.latest_episodes_for_user(user, @num_latest_episodes)
    end
    render conn, "index.html", %{episodes: episodes, page_title: "New releases"}
  end

  def episode(conn, %{"id" => id}) do
    episode = Episodes.get_episode!(id)
    page_title = "#{episode.podcast.title} - #{episode.title}"
    render conn, "episode.html", episode: episode, page_title: page_title
  end

  def search(conn, %{"q" => ""}) do
    render conn, "search.html", page_title: "Discover"
  end

  def search(conn, %{"q" => search_term} = params) do
    page = Episodes.search_episodes(search_term, params)
    render conn, "search.html", page: page, search_term: search_term, page_title: "Discover"
  end

  def search(conn, _params) do
    render conn, "search.html", page_title: "Discover"
  end

end
