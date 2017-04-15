defmodule Podcatcher.Accounts.User do
  use Ecto.Schema

  alias Podcatcher.Bookmarks.Bookmark

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true

    has_many :bookmarks, Bookmark

    timestamps()
  end
end
