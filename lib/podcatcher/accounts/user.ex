defmodule Podcatcher.Accounts.User do
  use Ecto.Schema

  schema "accounts_users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true

    timestamps()
  end
end
