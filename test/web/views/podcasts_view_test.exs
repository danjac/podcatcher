defmodule Podcatcher.Web.PodcastsViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Fixtures
  import Podcatcher.Web.PodcastsView

  test "podcast_url/2 should return link to podcast", %{conn: conn} do
    podcast = fixture(:podcast)
    assert podcast_url(conn, podcast) == "/podcast/#{podcast.id}/#{podcast.slug}"
  end

end
