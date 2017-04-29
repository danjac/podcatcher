defmodule Podcatcher.Web.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts
  alias Podcatcher.Episodes

  def index(conn, %{"q" => ""} = params), do: latest_podcasts(conn, params)

  def index(conn, %{"q" => search_term} = params) do
    page = Podcasts.search_podcasts(search_term, params)
    render conn, "index.html", %{page: page, search_term: search_term, page_title: "Discover"}
  end

  def index(conn, params), do: latest_podcasts(conn, params)

  def podcast(conn, %{"id" => id, "q" => search_term} = params) when search_term == "" do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.episodes_for_podcast(podcast, params)
    render conn, "podcast.html", %{podcast: podcast, page: page, page_title: podcast.title}
  end

  def podcast(conn, %{"id" => id, "q" => search_term} = params) do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.search_episodes_for_podcast(podcast, search_term, params)
    render conn, "search_episodes.html", %{
      podcast: podcast,
      page: page,
      search_term: search_term,
      page_title: podcast.title,
    }
  end

  def podcast(conn, %{"id" => id} = params) do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.episodes_for_podcast(podcast, params)
    render conn, "podcast.html", %{podcast: podcast, page: page, page_title: podcast.title}
  end

  defp latest_podcasts(conn, params) do
    page = Podcasts.latest_podcasts(params)
    render conn, "index.html", %{page: page, search_term: nil, page_title: "Discover"}
  end

end
