defmodule Podcatcher.Web.URLView do
  use Podcatcher.Web, :view

  def episode_url(conn, episode) do
    episodes_path(conn, :episode, episode.id, Slugify.slugify(episode))
  end

  def podcast_url(conn, podcast) do
    podcasts_path(conn, :podcast, podcast.id, podcast.slug)
  end

end
