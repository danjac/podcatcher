defmodule Podcatcher.Subscriptions.Subscription do
  use Ecto.Schema

  alias Podcatcher.Accounts.User
  alias Podcatcher.Podcasts.Podcast

  schema "subscriptions" do
    belongs_to :user, User
    belongs_to :podcast, Podcast

    timestamps()
  end
end
