defmodule Podcatcher.Repo.Migrations.AddParentCategory do
  use Ecto.Migration

  def change do

    alter table(:categories) do
      add :parent_id, references(:categories)
    end

  end
end
