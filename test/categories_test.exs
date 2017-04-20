defmodule Podcatcher.CategoriesTest do
  use Podcatcher.DataCase

  import Podcatcher.Fixtures

  alias Podcatcher.Categories
  alias Podcatcher.Categories.Category

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  test "fetch_categories/1 should fetch categories" do
    categories = Categories.fetch_categories(["TV and film", "comedy", "Arts"])
    assert length(categories) == 3
  end

  test "list_categories/1 returns all categories" do
    assert length(Categories.list_categories()) == 58
  end

  test "get_category! returns the category with given id" do
    category = fixture(:category)
    assert Categories.get_category!(category.id).id == category.id
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
    assert category.id == Categories.get_category!(category.id).id
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
