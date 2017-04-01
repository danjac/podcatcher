defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Categories.Category do
  use Ecto.Migration

  def change do
    create table(:categories_categories) do
      add :name, :string

      timestamps()
    end

    create unique_index(:categories_categories, [:name])
  end
end
