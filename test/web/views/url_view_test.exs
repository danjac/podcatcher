defmodule Podcatcher.Web.URLViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Fixtures
  import Podcatcher.Web.URLView

  test "episode_url/2 should return link to episode", %{conn: conn} do
    episode = fixture(:episode)
    assert episode_url(conn, episode) == "/episode/#{episode.id}/#{Slugger.slugify_downcase(episode.title)}"
  end

  test "podcast_url/2 should return link to podcast", %{conn: conn} do
    podcast = fixture(:podcast)
    assert podcast_url(conn, podcast) == "/podcast/#{podcast.id}/#{podcast.slug}"
  end


end
