defmodule Podcatcher.Podcasts.Podcast do
  use Ecto.Schema

  alias Podcatcher.Categories.Category

  schema "podcasts_podcasts" do
    field :copyright, :string
    field :description, :string
    field :email, :string
    field :explicit, :boolean, default: false
    field :image, Podcatcher.Uploaders.Image.Type
    field :owner, :string
    field :rss_feed, :string
    field :subtitle, :string
    field :title, :string
    field :website, :string

    many_to_many :categories, Category, join_through: "podcasts_categories"

    timestamps()
  end
end
