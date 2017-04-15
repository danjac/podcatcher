defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Bookmarks.Bookmark do
  use Ecto.Migration

  def change do
    create table(:bookmarks) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :episode_id, references(:episodes, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:bookmarks, [:user_id, :episode_id])

    create index(:bookmarks, [:user_id])
    create index(:bookmarks, [:episode_id])

  end
end
