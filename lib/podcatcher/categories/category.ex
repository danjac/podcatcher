defmodule Podcatcher.Categories.Category do
  use Ecto.Schema

  schema "categories_categories" do
    field :name, :string

    timestamps()
  end
end
