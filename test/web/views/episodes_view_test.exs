defmodule Podcatcher.Web.EpisodesViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.EpisodesView

  test "audio_ext/1 if nil returns empty string" do
    assert audio_ext(nil) == ""
  end

  test "audio_ext/1 if empty returns empty string" do
    assert audio_ext(nil) == ""
  end

  test "audio_ext/1 should return extension" do
    assert audio_ext("http://some-site.com/sample-episode.mp3") == "mp3"
  end

end
