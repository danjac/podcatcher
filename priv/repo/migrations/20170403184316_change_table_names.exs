defmodule Podcatcher.Repo.Migrations.ChangeTableNames do
  use Ecto.Migration

  def change do
    rename table(:episodes_episodes), to: table(:episodes)
    rename table(:podcasts_podcasts), to: table(:podcasts)
    rename table(:categories_categories), to: table(:categories)
  end
end
