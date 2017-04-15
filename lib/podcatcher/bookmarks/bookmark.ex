defmodule Podcatcher.Bookmarks.Bookmark do

  use Ecto.Schema

  alias Podcatcher.Episodes.Episode
  alias Podcatcher.Accounts.User

  schema "bookmarks" do
    belongs_to :episode, Episode
    belongs_to :user, User

    timestamps()
  end
end
