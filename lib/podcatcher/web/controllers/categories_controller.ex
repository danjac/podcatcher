defmodule Podcatcher.Web.CategoriesController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Categories
  alias Podcatcher.Podcasts

  def index(conn, _params) do
    categories = Categories.parent_categories()
    render conn, "index.html", %{categories: categories, page_title: "Browse"}
  end

  def category(conn, %{"id" => id, "q" => search_term} = params) when search_term != "" do
    category = Categories.get_category!(id)
    page = Podcasts.search_podcasts_for_category(category, search_term, params)
    render conn, "category.html", %{category: category, page: page, page_title: category.name, search_term: search_term}
  end

  def category(conn, %{"id" => id} = params) do
    category = Categories.get_category!(id)
    page = Podcasts.latest_podcasts_for_category(category, params)
    render conn, "category.html", %{category: category, page: page, page_title: category.name}
  end


end
