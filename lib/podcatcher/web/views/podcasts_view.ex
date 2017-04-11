defmodule Podcatcher.Web.PodcastsView do
  use Podcatcher.Web, :view

  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Podcasts.Image

  import Podcatcher.Web.Formatters

  def podcast_image(conn, %Podcast{image: image} = podcast, size) do
    case image do
      nil -> static_path(conn, "/images/rss-#{size}.png")
      _ -> Image.url {image, podcast}, size
    end
  end

  def podcast_url(conn, %Podcast{} = podcast) do
    podcasts_path(conn, :podcast, podcast.id, podcast.slug)
  end

end
