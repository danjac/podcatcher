defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Podcasts.Podcast do
  use Ecto.Migration

  def change do
    create table(:podcasts_podcasts) do
      add :rss_feed, :string
      add :website, :string
      add :title, :string
      add :description, :text
      add :subtitle, :text
      add :image, :string
      add :explicit, :boolean, default: false, null: false
      add :owner, :string
      add :email, :string
      add :copyright, :string

      timestamps()
    end

    create unique_index(:podcasts_podcasts, [:rss_feed])
  end
end
