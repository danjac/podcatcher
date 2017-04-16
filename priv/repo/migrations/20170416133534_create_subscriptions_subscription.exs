defmodule Podcatcher.Repo.Migrations.CreatePodcatcher.Subscriptions.Subscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :podcast_id, references(:podcasts, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:subscriptions, [:user_id, :podcast_id])

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:podcast_id])
  end
end
