defmodule Podcatcher.Web.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts
  alias Podcatcher.Episodes

  def index(conn, params) do
    # page = Podcasts.latest_podcasts(params)
    # render conn, "index.html", %{page: page}
  end

  def search(conn, %{"q" => search_term} = params) do
    # page = Podcasts.search_podcasts(search_term, params)
    # render conn, "search.html", %{page: page, search_term: search_term}
  end

  def podcast(conn, %{"id" => id} = params) do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.latest_episodes_for_podcast(podcast, params)
    render conn, "podcast.html", %{podcast: podcast, page: page}
  end
end
