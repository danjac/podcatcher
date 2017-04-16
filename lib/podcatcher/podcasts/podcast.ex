defmodule Podcatcher.Podcasts.Podcast do
  use Ecto.Schema

  alias Podcatcher.Categories.Category
  alias Podcatcher.Episodes.Episode
  alias Podcatcher.Podcasts.Image
  alias Podcatcher.Podcasts.Slug
  alias Podcatcher.Subscriptions.Subscription

  schema "podcasts" do
    field :title, :string
    field :slug, Slug.Type
    field :copyright, :string
    field :description, :string
    field :email, :string
    field :last_build_date, :naive_datetime
    field :explicit, :boolean, default: false
    field :image, Image.Type
    field :owner, :string
    field :rss_feed, :string
    field :subtitle, :string
    field :website, :string

    has_many :episodes, Episode
    has_many :subscriptions, Subscription
    many_to_many :categories, Category, join_through: "podcasts_categories", on_replace: :delete

    timestamps()
  end
end
