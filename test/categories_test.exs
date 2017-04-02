defmodule Podcatcher.CategoriesTest do
  use Podcatcher.DataCase

  alias Podcatcher.Categories
  alias Podcatcher.Categories.Category

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:category, attrs \\ @create_attrs) do
    {:ok, category} = Categories.create_category(attrs)
    category
  end

  test "get_or_create_categories/1 should create new categories if not already present" do
    names = ["TV & Film", "Comedy", "Arts"]
    categories = Categories.get_or_create_categories(names)
    assert length(categories) == 3

    new_categories = Categories.get_or_create_categories(["History" | names])
    assert length(new_categories) == 4

  end

  test "list_categories/1 returns all categories" do
    category = fixture(:category)
    assert Categories.list_categories() == [category]
  end

  test "get_category! returns the category with given id" do
    category = fixture(:category)
    assert Categories.get_category!(category.id) == category
  end

  test "create_category/1 with valid data creates a category" do
    assert {:ok, %Category{} = category} = Categories.create_category(@create_attrs)
    assert category.name == "some name"
  end

  test "create_category/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
  end

  test "update_category/2 with valid data updates the category" do
    category = fixture(:category)
    assert {:ok, category} = Categories.update_category(category, @update_attrs)
    assert %Category{} = category
    assert category.name == "some updated name"
  end

  test "update_category/2 with invalid data returns error changeset" do
    category = fixture(:category)
    assert {:error, %Ecto.Changeset{}} = Categories.update_category(category, @invalid_attrs)
    assert category == Categories.get_category!(category.id)
  end

  test "delete_category/1 deletes the category" do
    category = fixture(:category)
    assert {:ok, %Category{}} = Categories.delete_category(category)
    assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
  end

  test "change_category/1 returns a category changeset" do
    category = fixture(:category)
    assert %Ecto.Changeset{} = Categories.change_category(category)
  end
end
