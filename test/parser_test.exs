defmodule Podcatcher.ParserTest do
  use Podcatcher.DataCase

  alias Podcatcher.Parser.FeedParser

  test "parse/1 parses XML" do
    data = File.read!("./test/fixtures/sample.xml")
    |> FeedParser.parse
    assert data.podcast.title == "Fat Man on Batman"
    assert data.podcast.explicit
    assert length(data.episodes) == 164
    [episode | _] = data.episodes
    assert episode.title == "164: The LOGAN Review"
    assert length(data.categories) == 6
    assert Enum.member?(data.categories, "Comedy")
  end
end

