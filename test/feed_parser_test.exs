defmodule Podcatcher.ParserTest do
  use Podcatcher.DataCase

  alias Podcatcher.Podcasts.FeedParser

  test "parse/1 parses XML" do
    feed = File.read!("./test/fixtures/sample.xml") |> FeedParser.parse

    assert feed.podcast.title == "Fat Man on Batman"
    assert feed.podcast.explicit
    assert length(feed.episodes) == 164
    [episode | _] = feed.episodes
    assert episode.title == "164: The LOGAN Review"
    assert length(feed.categories) == 6
    assert Enum.member?(feed.categories, "Comedy")

    assert length(feed.images) == 2

    images = [
      "http://i1.sndcdn.com/avatars-000204810712-xboiiu-original.jpg",
      "http://www.viewaskew.com/PodArt/fatman-current.png",
    ]

    for image <- images, do: assert Enum.member?(feed.images, image)
  end
end

