defmodule Podcatcher.Categories.Category do
  use Ecto.Schema

  alias Podcatcher.Podcasts.Podcast

  schema "categories" do
    field :name, :string

    belongs_to :parent, Podcatcher.Categories.Category
    has_many :children, Podcatcher.Categories.Category, foreign_key: :parent_id

    many_to_many :podcasts, Podcast, join_through: "podcasts_categories"

    timestamps()
  end
end

defimpl Slugify, for: Podcatcher.Categories.Category do
  def slugify(category), do: Slugger.slugify_downcase(category.name)
end
