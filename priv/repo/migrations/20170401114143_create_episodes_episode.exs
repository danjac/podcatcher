defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Episodes.Episode do
  use Ecto.Migration

  def change do
    create table(:episodes_episodes) do
      add :guid, :string
      add :title, :string
      add :link, :string
      add :description, :text
      add :summary, :text
      add :subtitle, :text
      add :pub_date, :naive_datetime
      add :explicit, :boolean, default: false, null: false
      add :author, :string
      add :content_length, :integer
      add :content_url, :string
      add :content_type, :string
      add :duration, :string
      add :podcast_id, references(:podcasts_podcasts, on_delete: :delete_all, null: false)

      timestamps()
    end

    create unique_index(:episodes_episodes, [:guid, :podcast_id])
    create index(:episodes_episodes, [:podcast_id])
  end
end
