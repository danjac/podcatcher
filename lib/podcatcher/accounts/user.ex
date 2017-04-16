defmodule Podcatcher.Accounts.User do
  use Ecto.Schema

  alias Podcatcher.Bookmarks.Bookmark
  alias Podcatcher.Subscriptions.Subscription

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true

    has_many :bookmarks, Bookmark
    has_many :subscriptions, Subscription

    timestamps()
  end
end
