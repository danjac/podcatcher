defmodule Podcatcher.Bookmarks do
  @moduledoc """
  The boundary for the Bookmarks system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Bookmarks.Bookmark

  @doc """
  Returns paginated list of bookmarks for a user
  """
  def bookmarks_for_user(user, params \\ []) do
    Bookmark
    |> where(user_id: ^user.id)
    |> order_by([desc: :inserted_at])
    |> preload([:episode, [episode: :podcast]])
    |> Repo.paginate(params)
  end

 @doc """
  Creates a bookmark.
  """
  def create_bookmark(user, episode) do
    %Bookmark{user_id: user.id, episode_id: episode.id}
    |> Repo.insert()
  end

  @doc """
  Deletes a Bookmark.
  """
  def delete_bookmark(user, episode) do
    from(
      Bookmark,
      where: [user_id: ^user.id, episode_id: ^episode.id])
    |>
    Repo.delete_all()
  end

end
