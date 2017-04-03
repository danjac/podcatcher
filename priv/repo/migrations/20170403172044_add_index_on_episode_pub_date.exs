defmodule Podcatcher.Repo.Migrations.AddIndexOnEpisodePubDate do
  use Ecto.Migration

  def change do
    create index(:episodes_episodes, [:pub_date])
  end
end
