defmodule Podcatcher.Podcasts do
  @moduledoc """
  The boundary for the Podcasts system.
  """
  use Arc.Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias Podcatcher.Repo
  alias Podcatcher.Episodes
  alias Podcatcher.Categories
  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Parser.FeedParser

  @doc """
  Returns the list of podcasts.

  ## Examples

      iex> list_podcasts()
      [%Podcast{}, ...]

  """
  def list_podcasts do
    Repo.all(Podcast)
  end

  @doc """
  Gets a single podcast.

  Raises `Ecto.NoResultsError` if the Podcast does not exist.

  ## Examples

      iex> get_podcast!(123)
      %Podcast{}

      iex> get_podcast!(456)
      ** (Ecto.NoResultsError)

  """
  def get_podcast!(id), do: Repo.get!(Podcast, id)

  @doc """
  Creates a podcast.

  ## Examples

      iex> create_podcast(%{field: value})
      {:ok, %Podcast{}}

      iex> create_podcast(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_podcast(attrs \\ %{}, categories \\ nil) do
    %Podcast{}
    |> podcast_changeset(attrs, categories)
    |> Repo.insert()
  end

  @doc """
  Gets a podcast with the rss_feed. If it does not exist,
  creates a new podcast with episodes.

  Returns {:error, reason} if an error, otherwise tuple of
  {:ok, created, podcast} where created is boolean if new podcast
  was created or not
  """
  def get_or_create_podcast_from_rss_feed(url) do
    case Repo.get_by(Podcast, rss_feed: url) do
      nil ->
        with result = create_podcast_from_rss_feed(url) do
          case result do
            {:ok, {podcast, _}} -> {:ok, true, podcast}
            _ -> result
          end
        end
      %Podcast{} = podcast -> {:ok, false, podcast}
    end
  end

  @doc """
  Refreshes content of a podcast.
  Pulls latest rss feed and updates podcast, episodes and categories as appropriate.
  NOTE: episodes and categories should be preloaded!!

  Returns number of new episodes.
  """

  def update_podcast_from_rss_feed(%Podcast{rss_feed: url} = podcast) do
    feed = FeedParser.fetch_and_parse(url)

    case feed do
      {:error, reason} -> {:error, reason}
      _ ->
        # update podcast metadata

        # TBD: downloading image is costly. Only include
        # if the image is different

        categories = Categories.get_or_create_categories(feed.categories)

        update_podcast(podcast, feed.podcast, categories)

        # check if new episodes
        # all episodes have unique GUID. If GUID is not found in
        # current list of episodes then we should add that episode.

        guids = podcast.episodes
        |> Enum.map(fn(episode) -> episode.guid end)

        episodes = feed.episodes
        |> Enum.reject(fn(episode) -> Enum.member?(guids, episode.guid) end)
        Episodes.create_episodes(podcast, episodes)
    end

  end

  @doc """
  Creates a podcast from an RSS feed.
  Adds any categories and episodes to the podcast.

  If the podcast does not contain any episodes, then the podcast is NOT
  created.
  """
  def create_podcast_from_rss_feed(url) do
    feed = FeedParser.fetch_and_parse(url)
    case feed do
      {:error, reason} -> {:error, reason}
      _ ->
        Repo.transaction(fn ->

          categories = Categories.get_or_create_categories(feed.categories)

          {:ok, %Podcast{} = podcast} = feed.podcast
          |> Map.put(:rss_feed, url)
          |> create_podcast(categories)

          num_episodes = Episodes.create_episodes(podcast, feed.episodes)
          case num_episodes do
            0 -> Repo.rollback(:invalid_podcast)
            _ -> {podcast, num_episodes}
          end
        end)
    end
  end


  @doc """
  Updates a podcast.

  ## Examples

      iex> update_podcast(podcast, %{field: new_value})
      {:ok, %Podcast{}}

      iex> update_podcast(podcast, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_podcast(%Podcast{} = podcast, attrs, categories \\ nil) do
    podcast
    |> podcast_changeset(attrs, categories)
    |> Repo.update()
  end

  @doc """
  Deletes a Podcast.

  ## Examples

      iex> delete_podcast(podcast)
      {:ok, %Podcast{}}

      iex> delete_podcast(podcast)
      {:error, %Ecto.Changeset{}}

  """
  def delete_podcast(%Podcast{} = podcast) do
    Repo.delete(podcast)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking podcast changes.

  ## Examples

      iex> change_podcast(podcast)
      %Ecto.Changeset{source: %Podcast{}}

  """
  def change_podcast(%Podcast{} = podcast) do
    podcast_changeset(podcast, %{})
  end

  defp preload_if_categories(%Podcast{} = podcast, categories) do
    # ensure we have preloaded if we're addig categories
    case categories do
      [] -> podcast
      nil -> podcast
      _ -> Repo.preload(podcast, :categories)
    end
  end

  defp cast_categories(%Ecto.Changeset{} = changeset, categories) do
    case categories do
      [] -> changeset
      nil -> changeset
      _  -> changeset |> put_assoc(:categories, categories)
    end
  end

  defp podcast_changeset(%Podcast{} = podcast, attrs, categories \\ nil) do
    podcast
    |> preload_if_categories(categories)
    |> cast(attrs, [:rss_feed, :website, :title, :description, :subtitle, :image, :explicit, :owner, :email, :copyright])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:rss_feed, :title])
    |> unique_constraint(:rss_feed)
    |> cast_categories(categories)
  end

end
