defmodule Podcatcher.Web.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts
  alias Podcatcher.Episodes

  def podcast(conn, %{"id" => id} = params) do
    podcast = Podcasts.get_podcast!(id)
    page = Episodes.latest_episodes_for_podcast(podcast, params)
    render conn, "podcast.html", %{podcast: podcast, page: page}
  end
end
