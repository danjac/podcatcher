defmodule Podcatcher.Episodes do
  @moduledoc """
  The boundary for the Episodes system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Episodes.Episode

  @doc """
  Returns the list of episodes.

  ## Examples

      iex> list_episodes()
      [%Episode{}, ...]

  """
  def list_episodes do
    Repo.all(Episode) |> Repo.preload(:podcast)
  end

  @doc """
  Gets a single episode.

  Raises `Ecto.NoResultsError` if the Episode does not exist.

  ## Examples

      iex> get_episode!(123)
      %Episode{}

      iex> get_episode!(456)
      ** (Ecto.NoResultsError)

  """
  def get_episode!(id), do: Repo.get!(Episode, id) |> Repo.preload(:podcast)

  @doc """
  Creates a episode.

  ## Examples

      iex> create_episode(%{field: value})
      {:ok, %Episode{}}

      iex> create_episode(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_episode(podcast, attrs \\ %{}) do
    %Episode{podcast: podcast}
    |> episode_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates multiple episodes for a single podcast.
  Returns number created.
  """

  def create_episodes(podcast, episodes) do
      data_to_insert = episodes
      |> Enum.map(fn(episode) ->
        Map.merge(episode, %{
        podcast_id: podcast.id,
        inserted_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
      }) end)
      {num_episodes, _} = Repo.insert_all(Episode, data_to_insert)
      num_episodes
  end

  @doc """
  Updates a episode.

  ## Examples

      iex> update_episode(episode, %{field: new_value})
      {:ok, %Episode{}}

      iex> update_episode(episode, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> episode_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Episode.

  ## Examples

      iex> delete_episode(episode)
      {:ok, %Episode{}}

      iex> delete_episode(episode)
      {:error, %Ecto.Changeset{}}

  """
  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking episode changes.

  ## Examples

      iex> change_episode(episode)
      %Ecto.Changeset{source: %Episode{}}

  """
  def change_episode(%Episode{} = episode) do
    episode_changeset(episode, %{})
  end

  defp episode_changeset(%Episode{} = episode, attrs) do
    episode
    |> cast(attrs, [:guid, :title, :link, :description, :summary, :subtitle, :pub_date, :explicit, :author, :content_length, :content_url, :content_type, :duration])
    |> validate_required([:guid, :title, :pub_date, :explicit, :content_length, :content_url, :content_type, :duration])
    |> unique_constraint(:guid)
  end
end
