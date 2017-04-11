defmodule Podcatcher.Web.CategoriesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Categories
  alias Podcatcher.Podcasts

  def index(conn, _params) do
    categories = Categories.list_categories
    render conn, "index.html", %{categories: categories, page_title: "Browse"}
  end

  def category(conn, %{"id" => id} = params) do
    category = Categories.get_category!(id)
    page = Podcasts.latest_podcasts_for_category(category, params)
    render conn, "category.html", %{category: category, page: page, page_title: category.name}
  end

end
