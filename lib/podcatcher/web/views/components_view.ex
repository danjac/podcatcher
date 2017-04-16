defmodule Podcatcher.Web.ComponentsView do
  use Podcatcher.Web, :view

  import Podcatcher.Web.PodcastsView, only: [podcast_image: 3]

  def bookmarked?(conn, episode) do
    Enum.member?(conn.assigns[:bookmarks], episode.id)
  end

end
