defmodule Podcatcher.PodcastsTest do
  use Podcatcher.DataCase

  import Mock

  alias Podcatcher.Podcasts
  alias Podcatcher.Uploaders.Image
  alias Podcatcher.Podcasts.Podcast

  @create_attrs %{copyright: "some copyright", description: "some description", email: "some email", explicit: true, owner: "some owner", rss_feed: "some rss_feed", subtitle: "some subtitle", title: "some title", website: "some website"}
  @update_attrs %{copyright: "some updated copyright", description: "some updated description", email: "some updated email", explicit: false, owner: "some updated owner", rss_feed: "some updated rss_feed", subtitle: "some updated subtitle", title: "some updated title", website: "some updated website"}
  @invalid_attrs %{copyright: nil, description: nil, email: nil, explicit: nil, image: nil, owner: nil, rss_feed: nil, subtitle: nil, title: nil, website: nil}

  def fixture(:podcast, attrs \\ @create_attrs) do
    {:ok, podcast} = Podcasts.create_podcast(attrs)
    podcast
  end

  def fetch_mock_rss_feed(_url, _headers, _options) do
    body = File.read! "./test/fixtures/sample.xml"
    {:ok, %HTTPoison.Response{body: body, status_code: 200}}
  end

  def create_mock_image(_source) do
    {:ok, "test_image.jpg"}
  end

  test "create_podcast_from_rss_feed/1 should create a new podcast" do
    with_mocks([
      {HTTPoison, [], [get: &fetch_mock_rss_feed/3]},
      {Image, [], [store: &create_mock_image/1]},
      ]) do
      {:ok, %Podcast{} = podcast} = Podcasts.create_podcast_from_rss_feed("https://somefeed.xml")
      assert podcast.title == "Fat Man on Batman"
      assert length(podcast.episodes) == 164
    end
  end

  test "list_podcasts/1 returns all podcasts" do
    podcast = fixture(:podcast)
    assert Podcasts.list_podcasts() == [podcast]
  end

  test "get_podcast! returns the podcast with given id" do
    podcast = fixture(:podcast)
    assert Podcasts.get_podcast!(podcast.id) == podcast
  end

  test "create_podcast/1 with valid data creates a podcast" do
    assert {:ok, %Podcast{} = podcast} = Podcasts.create_podcast(@create_attrs)
    assert podcast.copyright == "some copyright"
    assert podcast.description == "some description"
    assert podcast.email == "some email"
    assert podcast.explicit == true
    assert podcast.owner == "some owner"
    assert podcast.rss_feed == "some rss_feed"
    assert podcast.subtitle == "some subtitle"
    assert podcast.title == "some title"
    assert podcast.website == "some website"
  end

  test "create_podcast/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Podcasts.create_podcast(@invalid_attrs)
  end

  test "update_podcast/2 with valid data updates the podcast" do
    podcast = fixture(:podcast)
    assert {:ok, podcast} = Podcasts.update_podcast(podcast, @update_attrs)
    assert %Podcast{} = podcast
    assert podcast.copyright == "some updated copyright"
    assert podcast.description == "some updated description"
    assert podcast.email == "some updated email"
    assert podcast.explicit == false
    assert podcast.owner == "some updated owner"
    assert podcast.rss_feed == "some updated rss_feed"
    assert podcast.subtitle == "some updated subtitle"
    assert podcast.title == "some updated title"
    assert podcast.website == "some updated website"
  end

  test "update_podcast/2 with invalid data returns error changeset" do
    podcast = fixture(:podcast)
    assert {:error, %Ecto.Changeset{}} = Podcasts.update_podcast(podcast, @invalid_attrs)
    assert podcast == Podcasts.get_podcast!(podcast.id)
  end

  test "delete_podcast/1 deletes the podcast" do
    podcast = fixture(:podcast)
    assert {:ok, %Podcast{}} = Podcasts.delete_podcast(podcast)
    assert_raise Ecto.NoResultsError, fn -> Podcasts.get_podcast!(podcast.id) end
  end

  test "change_podcast/1 returns a podcast changeset" do
    podcast = fixture(:podcast)
    assert %Ecto.Changeset{} = Podcasts.change_podcast(podcast)
  end
end
