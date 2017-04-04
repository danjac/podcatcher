defmodule Podcatcher.Podcasts.Podcast do
  use Ecto.Schema

  alias Podcatcher.Categories.Category
  alias Podcatcher.Episodes.Episode
  alias Podcatcher.Podcasts.Image

  schema "podcasts" do
    field :title, :string
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
    many_to_many :categories, Category, join_through: "podcasts_categories"

    timestamps()
  end
end
