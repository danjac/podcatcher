defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Podcasts.Podcast do
  use Ecto.Migration

  def change do
    create table(:podcasts_podcasts) do
      add :rss_feed, :string
      add :slug, :string
      add :website, :text
      add :title, :text
      add :description, :text
      add :subtitle, :text
      add :image, :string
      add :explicit, :boolean, default: false, null: false
      add :owner, :string
      add :email, :string
      add :copyright, :string

      timestamps()
    end

    create unique_index(:podcasts_podcasts, [:slug, :rss_feed])
  end
end
