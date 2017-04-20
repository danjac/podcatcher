defmodule Podcatcher.Web.EpisodesViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.EpisodesView

  test "audio_mimetype/1 if nil returns empty string" do
    assert audio_mimetype(nil) == ""
  end

  test "audio_mimetype/1 if empty returns empty string" do
    assert audio_mimetype(nil) == ""
  end

  test "audio_mimetype/1 should return mime type" do
    assert audio_mimetype("http://some-site.com/sample-episode.mp3") == "audio/mpeg"
  end

  test "safe_protocol/1 if nil returns empty string" do
    assert safe_protocol(nil) == ""
  end

  test "safe_protocol/1 if empty returns empty string" do
    assert safe_protocol(nil) == ""
  end

  test "safe_protocol/1 should remove http" do
    assert safe_protocol("http://some-site.com/sample-episode.mp3") == "//some-site.com/sample-episode.mp3"
  end

  test "safe_protocol/1 should remove https" do
    assert safe_protocol("https://some-site.com/sample-episode.mp3") == "//some-site.com/sample-episode.mp3"
  end




end
