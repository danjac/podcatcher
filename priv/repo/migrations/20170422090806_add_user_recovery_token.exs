defmodule Podcatcher.Repo.Migrations.AddUserRecoveryToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :recovery_token, :string
    end
  end
end
