defmodule Podcatcher.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Accounts.User

  @min_password_length 6
  @token_length 12

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
  Gets a single user. Preloads bookmarks and subscriptions for user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  """

  def get_user!(id), do: Repo.get!(User, id) |> preload_all

  @doc """
  Gets a single user. Returns nil if user not found. Preloads bookmarks and subscriptions for user.
  """

  def get_user(id), do: Repo.get(User, id) |> preload_all

  defp preload_all(user) when is_nil(user), do: nil
  defp preload_all(user), do: Repo.preload(user, [:bookmarks, :subscriptions])

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
  Updates user password.
  """
  def update_password(%User{} = user, attrs) do
    user
    |> password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user email address.
  """
  def update_email(%User{} = user, attrs) do
    user
    |> email_changeset(attrs)
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
  def change_user(user \\ %User{}) do
    user_changeset(user, %{})
  end

  @doc """
  Returns `%Ecto.Changeset{}` for changing the user password.
  """
  def change_password(user \\ %User{}) do
    password_changeset(user, %{})
  end

  @doc """
  Returns `%Ecto.Changeset{}` for changing the user email address.
  """
  def change_email(user \\ %User{}) do
    email_changeset(user, %{})
  end

  @doc """
  Generates and saves unique token for user
  """
  def generate_recovery_token!(user) do
    token = :crypto.strong_rand_bytes(@token_length)
    |> Base.url_encode64
    |> binary_part(0, @token_length)

    user
    |> cast(%{recovery_token: token}, [:recovery_token])
    |> Repo.update!

    token
  end

  def get_user_by_token!(token), do: Repo.get_by!(User, recovery_token: token)

  def get_user_by_name_or_email(identifier) do
    from(u in User, where: u.email==^identifier or u.name==^identifier) |> Repo.one
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
    get_user_by_name_or_email(identifier) |> do_authenticate(password)
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

  defp email_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, name: :accounts_users_email_index)
  end

  defp password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: @min_password_length)
    |> validate_confirmation(:password)
    |> put_change(:recovery_token, nil)
    |> encrypt_password()
  end

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: @min_password_length)
    |> validate_confirmation(:password)
    |> unique_constraint(:name, name: :accounts_users_name_index)
    |> unique_constraint(:email, name: :accounts_users_email_index)
    |> encrypt_password()
  end
end
