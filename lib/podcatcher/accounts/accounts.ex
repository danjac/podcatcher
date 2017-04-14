defmodule Podcatcher.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> user_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    user_changeset(user, %{})
  end

  @doc """
  Checks hashed password

  ## Examples
      iex> check_password("testpass", "some hash")
      false
  """
  def check_password(password, hash) do
    Comeonin.Bcrypt.checkpw(password, hash)
  end

  @doc """
  Authenticates user name or email and password, and returns a user.
  """

  def authenticate(identifier, _password) when identifier == "" or is_nil(identifier), do: {:error, :invalid_params}
  def authenticate(_identifier, password) when password == "" or is_nil(password), do: {:error, :invalid_params}

  def authenticate(identifier, password) do
    from(u in User, where: u.email==^identifier or u.name==^identifier) |> Repo.one |> do_authenticate(password)
  end

  defp do_authenticate(nil, _password), do: {:error, :user_not_found}

  defp do_authenticate(%User{} = user, password) do
    case check_password(password, user.password) do
      true -> user
      false -> {:error, :invalid_password}
    end
  end

  defp encrypt_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password, Comeonin.Bcrypt.hashpwsalt(password))
  end

  defp encrypt_password(%Ecto.Changeset{} = changeset), do: changeset

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> encrypt_password()
    |> unique_constraint(:name)
    |> unique_constraint(:email)
  end
end
