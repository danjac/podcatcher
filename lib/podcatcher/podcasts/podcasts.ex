defmodule Podcatcher.Podcasts do
  @moduledoc """
  The boundary for the Podcasts system.
  """
  use Arc.Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias Podcatcher.Repo
  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Episodes.Episode
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
  def create_podcast(attrs \\ %{}) do
    %Podcast{}
    |> podcast_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a podcast with the rss_feed. If it does not exist,
  creates a new podcast with episodes.
  """
  def get_or_create_podcast_from_rss_feed(url) do
    case Repo.get_by(Podcast, rss_feed: url) do
      nil ->
        with result = create_podcast_from_rss_feed(url) do
          case result do
            {:ok, {podcast, _}} -> {:ok, podcast}
            _ -> result
          end
        end
      %Podcast{} = podcast -> {:ok, podcast}
    end
  end

  @doc """
  Creates a podcast from an RSS feed.
  Adds any categories and episodes to the podcast.

  If the podcast does not contain any episodes, then the podcast is NOT
  created.
  """
  def create_podcast_from_rss_feed(url) do
    data = FeedParser.fetch_and_parse(url)
    case data do
      {:error, reason} -> {:error, reason}
      _ ->
        Repo.transaction(fn ->
          {:ok, %Podcast{} = podcast} = create_podcast(Map.put(data.podcast, :rss_feed, url))
          episodes = data.episodes
          |> Enum.filter(fn(episode) -> episode.content_url != "" end)
          |> Enum.map(fn(episode) ->
            Map.merge(episode, %{
            podcast_id: podcast.id,
            inserted_at: DateTime.utc_now,
            updated_at: DateTime.utc_now,
          }) end)
          {num_episodes, _} = Repo.insert_all(Episode, episodes)
          case num_episodes do
            0 ->
            Repo.rollback(:invalid_podcast)
            _ ->
            {podcast, num_episodes}
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
  def update_podcast(%Podcast{} = podcast, attrs) do
    podcast
    |> podcast_changeset(attrs)
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

  defp podcast_changeset(%Podcast{} = podcast, attrs) do
    podcast
    |> cast(attrs, [:rss_feed, :website, :title, :description, :subtitle, :image, :explicit, :owner, :email, :copyright])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:rss_feed, :title])
    |> unique_constraint(:rss_feed)
  end
end
