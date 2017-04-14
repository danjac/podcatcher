defmodule Podcatcher.Fixtures do

  alias Podcatcher.{Accounts,Categories,Episodes,Podcasts}

  @episode_attrs %{author: "some author", content_length: 42, content_type: "some content_type", content_url: "some content_url", description: "some description", duration: "some duration", explicit: true, guid: :random, link: "some link", pub_date: ~N[2010-04-17 14:00:00.000000], subtitle: "some subtitle", summary: "some summary", title: "some title"}

  @podcast_attrs %{copyright: "some copyright", description: "some description", email: "some email", explicit: true, owner: "some owner", subtitle: "some subtitle", title: "some title", website: "some website", last_build_date: ~N[2011-05-18 15:01:01.000000]}


  def random_string(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64
    |> binary_part(0, len)
  end

  def podcast_attrs do
    Map.merge(@podcast_attrs, %{rss_feed: "http://#{random_string(30)}.xml"})
  end

  def episode_attrs do
    Map.merge(@episode_attrs, %{guid: random_string(20)})
  end

  def user_attrs do
    %{
      name: random_string(6),
      email: "#{random_string(6)}@gmail.com",
      password: "testpass",
      password_confirmation: "testpass",
    }
  end

  def fixture(:podcast) do
    {:ok, podcast} = Podcasts.create_podcast(podcast_attrs())
    podcast
  end

  def fixture(:category) do
    {:ok, category} = Categories.create_category %{name: random_string(10)}
    category
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(user_attrs())
    user
  end

  def fixture(:episode, podcast \\ nil) do
    {:ok, episode} = Episodes.create_episode(podcast || fixture(:podcast), episode_attrs())
    episode
  end

end
