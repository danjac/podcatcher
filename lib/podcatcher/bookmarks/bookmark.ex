defmodule Podcatcher.Bookmarks.Bookmark do
  use Ecto.Schema

  schema "bookmarks" do
    field :user_id, :id
    field :episode_id, :id

    timestamps()
  end
end
