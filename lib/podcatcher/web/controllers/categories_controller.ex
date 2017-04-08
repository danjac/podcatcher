defmodule Podcatcher.Web.CategoriesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Categories
  alias Podcatcher.Podcasts

  def index(conn, _params) do
    categories = Categories.list_categories
    render conn, "index.html", %{categories: categories}
  end

  def category(conn, %{"id" => id}) do
    category = Categories.get_category!(id)
    # page = Podcasts.latest_podcasts_for_category(category)
    render conn, "category.html", %{category: category}
  end

end
