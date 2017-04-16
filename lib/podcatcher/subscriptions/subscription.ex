defmodule Podcatcher.Subscriptions.Subscription do
  use Ecto.Schema

  alias Podcatcher.Accounts.User
  alias Podcatcher.Podcasts.Podcast

  schema "subscriptions" do
    belongs_to :user_id, User
    belongs_to :podcast_id, Podcast

    timestamps()
  end
end
