defmodule Podcatcher.Web.ComponentsView do
  use Podcatcher.Web, :view

  import Podcatcher.Web.PodcastsView, only: [podcast_image: 3]

  def bookmarked?(conn, episode) do
    case conn.assigns[:bookmarks] do
      nil -> false
      bookmarks -> Enum.member?(bookmarks, episode.id)
    end
  end

  def subscribed?(conn, podcast) do
    case conn.assigns[:subscriptions] do
      nil -> false
      subscriptions -> Enum.member?(subscriptions, podcast.id)
    end
  end

end
