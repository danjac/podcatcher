defmodule Podcatcher.Repo.Migrations.AddLastBuildDateToPodcast do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :last_build_date, :naive_datetime
    end
  end
end
