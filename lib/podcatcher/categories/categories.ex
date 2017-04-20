defmodule Podcatcher.Categories do
  @moduledoc """
  The boundary for the Categories system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Categories.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Category
    |> order_by(:name)
    |> Repo.all
    |> Repo.preload(:parent)
  end

  def parent_categories do
    from(
      c in Category,
      where: is_nil(c.parent_id),
      order_by: :name,
      preload: :children,
    )
    |> Repo.all
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload([:parent, :children])
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> category_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetches list of categories with matching names
  """
  def fetch_categories(names) do
    names =
      names
      |> Enum.map(fn(name) ->
        name
        |> String.replace(" and ", " & ")
        |> String.replace(" &amp; ", " & ")
        |> String.downcase
      end)

    Category
    |> Repo.all
    |> Enum.filter(&(String.downcase(&1.name) in names))

  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> category_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    category_changeset(category, %{})
  end

  defp category_changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
