defmodule Podcatcher.Categories.Category do
  use Ecto.Schema

  alias Podcatcher.Podcasts.Podcast

  schema "categories" do
    field :name, :string

    many_to_many :podcasts, Podcast, join_through: "podcasts_categories"

    timestamps()
  end
end

defimpl Slugify, for: Podcatcher.Categories.Category do
  def slugify(category), do: Slugger.slugify_downcase(category.name)
end
