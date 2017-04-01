defmodule Podcatcher.Categories.Category do
  use Ecto.Schema

  alias Podcatcher.Podcasts.Podcast

  schema "categories_categories" do
    field :name, :string

    many_to_many :podcasts, Podcast, join_through: "podcasts_categories"

    timestamps()
  end
end
