defmodule Podcatcher.Web.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts
  alias Podcatcher.Episodes

  def index(conn, %{"q" => search_term} = params) do
    page = Podcasts.search_podcasts(search_term, params)
    render conn, "index.html", %{page: page, search_term: search_term}
  end

  def index(conn, params) do
    page = Podcasts.latest_podcasts(params)
    render conn, "index.html", %{page: page, search_term: nil}
  end

  def podcast(conn, %{"id" => id} = params) do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.episodes_for_podcast(podcast, params)
    render conn, "podcast.html", %{podcast: podcast, page: page}
  end
end
