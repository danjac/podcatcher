defmodule Podcatcher.Repo.Migrations.ChangeUsersTableName do
  use Ecto.Migration

  def change do
    rename table(:accounts_users), to: table(:users)
  end
end
