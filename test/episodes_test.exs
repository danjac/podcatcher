defmodule Podcatcher.EpisodesTest do
  use Podcatcher.DataCase

  import Podcatcher.Fixtures

  alias Podcatcher.Episodes
  alias Podcatcher.Episodes.Episode

  @create_attrs %{author: "some author", content_length: 42, content_type: "some content_type", content_url: "some content_url", description: "some description", duration: "some duration", explicit: true, guid: "some guid", link: "some link", pub_date: ~N[2010-04-17 14:00:00.000000], subtitle: "some subtitle", summary: "some summary", title: "some title"}
  @update_attrs %{author: "some updated author", content_length: 43, content_type: "some updated content_type", content_url: "some updated content_url", description: "some updated description", duration: "some updated duration", explicit: false, guid: "some updated guid", link: "some updated link", pub_date: ~N[2011-05-18 15:01:01.000000], subtitle: "some updated subtitle", summary: "some updated summary", title: "some updated title"}
  @invalid_attrs %{author: nil, content_length: nil, content_type: nil, content_url: nil, description: nil, duration: nil, explicit: nil, guid: nil, link: nil, pub_date: nil, subtitle: nil, summary: nil, title: nil}

  test "create_episodes/2 should create new episodes" do
    podcast = fixture(:podcast)
    episodes = for guid <- 1..10 do
      %{ @create_attrs | guid: to_string(guid) }
    end
    num_episodes = Episodes.create_episodes(podcast, episodes)
    assert num_episodes == 10
  end

  test "latest_episodes/0 returns first page of episodes" do
    episode = fixture(:episode)
    assert Episodes.latest_episodes().entries == [episode]
  end

  test "latest_episodes_for_podcast/1 returns page of episodes for a podcast" do
    podcast = fixture(:podcast)
    episode = fixture(:episode, podcast)
    [first | _ ] = Episodes.latest_episodes_for_podcast(podcast).entries
    assert first.id == episode.id
  end

  test "get_episode! returns the episode with given id" do
    episode = fixture(:episode)
    assert Episodes.get_episode!(episode.id).id == episode.id
  end

  test "create_episode/1 with valid data creates a episode" do
    podcast = fixture(:podcast)
    assert {:ok, %Episode{} = episode} = Episodes.create_episode(podcast, @create_attrs)
    assert episode.author == "some author"
    assert episode.content_length == 42
    assert episode.content_type == "some content_type"
    assert episode.content_url == "some content_url"
    assert episode.description == "some description"
    assert episode.duration == "some duration"
    assert episode.explicit == true
    assert episode.guid == "some guid"
    assert episode.link == "some link"
    assert episode.pub_date == ~N[2010-04-17 14:00:00.000000]
    assert episode.subtitle == "some subtitle"
    assert episode.summary == "some summary"
    assert episode.title == "some title"
  end

  test "create_episode/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Episodes.create_episode(@invalid_attrs)
  end

  test "update_episode/2 with valid data updates the episode" do
    episode = fixture(:episode)
    assert {:ok, episode} = Episodes.update_episode(episode, @update_attrs)
    assert %Episode{} = episode
    assert episode.author == "some updated author"
    assert episode.content_length == 43
    assert episode.content_type == "some updated content_type"
    assert episode.content_url == "some updated content_url"
    assert episode.description == "some updated description"
    assert episode.duration == "some updated duration"
    assert episode.explicit == false
    assert episode.guid == "some updated guid"
    assert episode.link == "some updated link"
    assert episode.pub_date == ~N[2011-05-18 15:01:01.000000]
    assert episode.subtitle == "some updated subtitle"
    assert episode.summary == "some updated summary"
    assert episode.title == "some updated title"
  end

  test "update_episode/2 with invalid data returns error changeset" do
    episode = fixture(:episode)
    assert {:error, %Ecto.Changeset{}} = Episodes.update_episode(episode, @invalid_attrs)
    assert episode.id == Episodes.get_episode!(episode.id).id
  end

  test "delete_episode/1 deletes the episode" do
    episode = fixture(:episode)
    assert {:ok, %Episode{}} = Episodes.delete_episode(episode)
    assert_raise Ecto.NoResultsError, fn -> Episodes.get_episode!(episode.id) end
  end

  test "change_episode/1 returns a episode changeset" do
    episode = fixture(:episode)
    assert %Ecto.Changeset{} = Episodes.change_episode(episode)
  end
end
