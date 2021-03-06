defmodule Podcatcher.Episodes do
  @moduledoc """
  The boundary for the Episodes system.
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Podcatcher.Repo

  alias Podcatcher.Categories.Category
  alias Podcatcher.Episodes.Episode

  @doc """
  Returns list of latest episodes by pub_date. Filters any episodes without a pub_date.

  # TBD : we shouldn't include episodes without a pub_date: this is an issue
  with date parsing certain formats. When fixed we can remove the filter.
  """
  def latest_episodes(limit) do
    from(
      e in Episode,
      where: not is_nil(e.pub_date),
      order_by: [desc: :pub_date],
      preload: :podcast,
      limit: ^limit,
    )
    |> Repo.all()
  end

  @doc """
  Returns list of latest episodes by pub_date that a user is subscribed to
  """
  def latest_episodes_for_user(user, limit) do
    from(
      e in Episode,
      join: p in assoc(e, :podcast),
      join: s in assoc(p, :subscriptions),
      where: s.user_id == ^user.id,
      order_by: [desc: e.pub_date],
      limit: ^limit,
      preload: [:podcast],
    )
    |> Repo.all
  end

  defp search(term) do
    Episode |> where(fragment("tsv @@ plainto_tsquery(?)", ^term))
  end

  @doc """
  Returns paginated search result, ordered by pub_date.
  """
  def search_episodes(term, params \\ []) do
    search(term)
    |> order_by([desc: :pub_date])
    |> preload(:podcast)
    |> Repo.paginate(params)
  end

  @doc """
  Returns paginated search result, ordered by pub_date.
  """
  def search_episodes_for_podcast(podcast, term, params \\ []) do
    search(term)
    |> where(podcast_id: ^podcast.id)
    |> order_by([desc: :pub_date])
    |> Repo.paginate(params)
  end

  @doc """
  Returns page of latest (by pub_date) episodes for a specific podcast.
  """
  def episodes_for_podcast(podcast, params \\ []) do

    Episode
    |> where(podcast_id: ^podcast.id)
    |> order_by([desc: :pub_date])
    |> Repo.paginate(params)

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
  def get_episode!(id) do
    Repo.get!(Episode, id)
    |> Repo.preload([:podcast, [podcast: [categories: (from c in Category, order_by: :name)]]])
  end

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
      {num_episodes, _} = Repo.insert_all(Episode, data_to_insert, on_conflict: :nothing)
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
    |> cast(attrs, [:guid, :title, :link, :description, :summary, :subtitle, :pub_date, :explicit, :author, :content_length, :content_url, :content_type, :duration, :keywords])
    |> validate_required([:guid, :title, :pub_date, :explicit, :content_length, :content_url, :content_type, :duration])
    |> unique_constraint(:guid)
  end
end
