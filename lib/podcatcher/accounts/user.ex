defmodule Podcatcher.Accounts.User do
  use Ecto.Schema

  schema "accounts_users" do
    field :email, :string
    field :name, :string
    field :password, :string

    timestamps()
  end
end
