defmodule Podcatcher.Web.URLHelpers do
  import Podcatcher.Web.Router.Helpers
  import Phoenix.HTML, only: [html_escape: 1]

  alias Podcatcher.Web.PaginationView

  def episode_url(conn, episode) do
    episodes_path(conn, :episode, episode.id, Slugify.slugify(episode))
  end

  def category_url(conn, category) do
    categories_path(conn, :category, category.id, Slugify.slugify(category))
  end

  def podcast_url(conn, podcast) do
    podcasts_path(conn, :podcast, podcast.id, podcast.slug)
  end

  def paginate(%Plug.Conn{} = conn, page, fun) do
    pagination_html = PaginationView.render("pagination.html", conn: conn, page: page)
    html_escape [pagination_html, fun.(), pagination_html]
  end

end
