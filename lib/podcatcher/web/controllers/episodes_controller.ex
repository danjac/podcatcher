defmodule Podcatcher.Web.EpisodesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Episodes

  @num_latest_episodes 21

  def index(%Plug.Conn{assigns: %{user: _}} = conn, %{"t" => "all"}) do
    episodes = Episodes.latest_episodes(@num_latest_episodes)
    render_episodes(conn, episodes, "all")
  end

  def index(%Plug.Conn{assigns: %{user: user}} = conn, _params) do
    episodes = Episodes.latest_episodes_for_user(user, @num_latest_episodes)
    render_episodes(conn, episodes, "user")
  end

  def index(conn, _params) do
    episodes = Episodes.latest_episodes(@num_latest_episodes)
    render_episodes(conn, episodes, "all")
  end

  defp render_episodes(conn, episodes, tab) do
    render conn, "index.html", %{episodes: episodes, page_title: "New releases", tab: tab}
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
