defmodule Podcatcher.Repo.Migrations.AddPodcastsCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:podcasts_categories, primary_key: false) do
      add :podcast_id, references(:podcasts_podcasts, on_delete: :delete_all, null: false)
      add :category_id, references(:categories_categories, on_delete: :delete_all, null: false)
    end

    create unique_index(:podcasts_categories, [:podcast_id, :category_id])
  end
end
