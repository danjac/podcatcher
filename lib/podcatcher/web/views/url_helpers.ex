defmodule Podcatcher.Web.URLHelpers do
  import Podcatcher.Web.Router.Helpers

  def episode_url(conn, episode) do
    episodes_path(conn, :episode, episode.id, Slugify.slugify(episode))
  end

  def category_url(conn, category) do
    categories_path(conn, :category, category.id, Slugify.slugify(category))
  end

  def podcast_url(conn, podcast) do
    podcasts_path(conn, :podcast, podcast.id, podcast.slug)
  end

end
