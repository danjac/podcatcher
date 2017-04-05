defmodule Podcatcher.Web.EpisodesView do
  use Podcatcher.Web, :view

  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Podcasts.Image

  # this will be moved to PodcastsView later
  def podcast_image(conn, %Podcast{image: image} = podcast, size) do
    case image do
      nil -> static_path(conn, "/images/rss-#{size}.png")
      _ -> Image.url {image, podcast}, size
    end
  end

  def truncate(value, max_length)  do
    cond do
      String.length(value) < max_length -> value
      true -> "#{value |> String.slice(0, (max_length - 3))}..."
    end
  end
end
