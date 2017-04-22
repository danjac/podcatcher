defmodule Podcatcher.AccountsTest do
  use Podcatcher.DataCase

  alias Podcatcher.Accounts
  alias Podcatcher.Accounts.User

  import Podcatcher.Fixtures

  @create_attrs %{email: "someone@gmail.com", name: "some name", password: "some password", password_confirmation: "some password"}
  @update_attrs %{email: "someone-else@gmail.com", name: "some updated name", password: "some updated password", password_confirmation: "some updated password"}
  @invalid_attrs %{email: nil, name: nil, password: nil}

  test "list_users/1 returns all users" do
    user = fixture(:user)
    [first | _] = Accounts.list_users()
    assert first.id == user.id
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert Accounts.get_user!(user.id).id == user.id
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs)
    assert user.email == "someone@gmail.com"
    assert user.name == "some name"
    assert Accounts.check_password("some password", user.password)
  end

  test "create_user/1 with same username returns error changeset" do
    attrs = %{ @create_attrs | name: "danjac" }
    assert {:ok, %User{}} = Accounts.create_user(attrs)
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
  end

  test "create_user/1 with invalid confirmation returns error changeset" do
    attrs = Map.put(@create_attrs, :password_confirmation, "something different")
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "someone-else@gmail.com"
    assert user.name == "some updated name"
    assert Accounts.check_password("some updated password", user.password)
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert user.id == Accounts.get_user!(user.id).id
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end

  test "authenticate/2 returns a user with the correct name and password" do
    user = fixture(:user)
    assert Accounts.authenticate(user.name, "testpass").id == user.id
  end

  test "authenticate/2 returns a user with the correct email and password" do
    user = fixture(:user)
    assert Accounts.authenticate(user.email, "testpass").id == user.id
  end

  test "authenticate/2 returns :error if name or email not found" do
    assert {:error, :user_not_found} = Accounts.authenticate("someone@gmail.com", "testpass")
  end

  test "authenticate/2 returns :error if password invalid" do
    user = fixture(:user)
    assert {:error, :invalid_password} = Accounts.authenticate(user.email, "testpass1")
  end

  test "generate_recovery_token/2 should create a new random token for a user" do
    user = fixture(:user)
    token = Accounts.generate_recovery_token(user)
    user = Accounts.get_user!(user.id)
    assert user.recovery_token == token
  end

end

