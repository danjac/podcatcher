defmodule Podcatcher.Podcasts do
  require Logger
  @moduledoc """
  The boundary for the Podcasts system.
  """
  use Arc.Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias Podcatcher.{Repo, Episodes, Categories}
  alias Podcatcher.Podcasts.{Podcast, Slug, FeedParser}
  alias Podcatcher.Categories.Category

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
  Returns page of latest podcasts (by last_build_date). Podcasts missing
  last_build_date are omitted.
  """

  def latest_podcasts(params \\ []) do
    from(
      p in Podcast,
      where: not is_nil(p.last_build_date),
      order_by: [desc: p.last_build_date],
    ) |> Repo.paginate(params)
  end

  @doc """
  Returns page of latest podcasts (by last_build_date) for a given category.
  """
  def latest_podcasts_for_category(category, params \\ []) do
    Podcast
    |> for_category(category)
    |> order_by([desc: :last_build_date, asc: :title])
    |> Repo.paginate(params)
  end

  @doc """
  Searches for podcasts. Returns paginated result, ordered
  by relevance.
  """

  def search_podcasts(term, params \\ []) do
    Podcast
    |> search(term)
    |> Repo.paginate(params)
  end

  @doc """
  Searches for podcasts for a given category
  """
  def search_podcasts_for_category(category, term, params \\ []) do
    Podcast
    |> search(term)
    |> for_category(category)
    |> Repo.paginate(params)
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
  def get_podcast!(id) do
    Repo.get!(Podcast, id)
    |> Repo.preload(categories: (from c in Category, order_by: :name))
  end

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

  Returns number of new episodes or {:error, reason}
  """

  def update_podcast_from_rss_feed(%Podcast{rss_feed: url} = podcast) do
    feed = FeedParser.fetch_and_parse(url)
    case feed do
      {:error, reason} -> {:error, reason}
      _ ->

        if should_update(podcast, feed) do

          attrs =
            feed.podcast
            |> Map.merge(%{
              image: feed.images,
              categories: Categories.fetch_categories(feed.categories)
            })

          podcast |> update_podcast(attrs)

          Episodes.create_episodes(podcast, feed.episodes)
        else
          0
        end
    end

  end

  defp should_update(%Podcast{last_build_date: nil}, %{}), do: true

  defp should_update(%Podcast{}, %{podcast: %{last_build_date: nil}}), do: true

  defp should_update(%Podcast{} = podcast, %{podcast: %{last_build_date: last_build_date}}) do
    DateTime.compare(last_build_date, DateTime.from_naive!(podcast.last_build_date, "Etc/UTC")) == :gt
  end

  defp should_update(_podcast, _feed), do: true

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

          {:ok, %Podcast{} = podcast} = feed.podcast
          |> Map.merge(%{
            rss_feed: url,
            categories: Categories.fetch_categories(feed.categories),
            image: feed.images
          }) |> create_podcast

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

  defp for_category(q, category) do
    q
    |> join(:left, [p], c in assoc(p, :categories))
    |> where([_, c], c.id == ^category.id)
  end

  defp search(q, term) do
    q
    |> where(fragment("tsv @@ plainto_tsquery(?)", ^term))
    |> order_by(fragment("ts_rank(tsv, plainto_tsquery(?)) DESC", ^term))
  end

  defp put_categories_assoc(%Ecto.Changeset{} = changeset, %{categories: categories}), do: put_assoc(changeset, :categories, categories)
  defp put_categories_assoc(%Ecto.Changeset{} = changeset, _), do: changeset

  # feed has a list of image URLs; try each one until we get a working download

  def maybe_save_image(%Ecto.Changeset{} = changeset, %{image: images}) when is_list(images), do: do_save_image(changeset, images)
  def maybe_save_image(%Ecto.Changeset{} = changeset, %{image: image}) , do: do_save_image(changeset, [image])
  def maybe_save_image(%Ecto.Changeset{} = changeset, _) , do: changeset

  defp do_save_image(%Ecto.Changeset{} = changeset, []), do: changeset
  defp do_save_image(%Ecto.Changeset{} = changeset, [nil | images]), do: do_save_image(changeset, images)
  defp do_save_image(%Ecto.Changeset{} = changeset, ["" | images]), do: do_save_image(changeset, images)

  defp do_save_image(%Ecto.Changeset{} = changeset, [image | images]) do
    try do

      new_changeset = cast_attachments(changeset, %{image: image}, [:image], allow_paths: true)
      case new_changeset.valid? do
        true  -> new_changeset
        false -> do_save_image(changeset, images)
      end

    rescue # some crapshoot with HTTPoison maybe?
      reason ->
        Logger.error("Image error: #{inspect reason}")
        do_save_image(changeset, images)
    end
  end

  defp podcast_changeset(%Podcast{} = podcast, attrs) do
      podcast
      |> Repo.preload(:categories)
      |> cast(attrs, [:rss_feed, :website, :last_build_date, :title, :description, :subtitle, :explicit, :owner, :email, :copyright, :keywords])
      |> validate_required([:rss_feed, :title])
      |> unique_constraint(:rss_feed)
      |> Slug.maybe_generate_slug
      |> Slug.unique_constraint
      |> maybe_save_image(attrs)
      |> put_categories_assoc(attrs)
  end

end
