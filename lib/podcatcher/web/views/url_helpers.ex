defmodule Podcatcher.Web.URLHelpers do
  import Podcatcher.Web.Router.Helpers
  import Phoenix.HTML, only: [html_escape: 1]

  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Podcasts.Image
  alias Podcatcher.Web.PaginationView

  def episode_url(conn, episode) do
    episodes_path(conn, :episode, episode.id, Slugify.slugify(episode))
  end

  def category_url(conn, category) do
    categories_path(conn, :category, category.id, Slugify.slugify(category))
  end

  def podcast_url(conn, podcast) do
    podcasts_path(conn, :podcast, podcast.id, podcast.slug || "")
  end

  def podcast_image(conn, %Podcast{image: image} = podcast, size) do
    case image do
      nil -> static_path(conn, "/images/rss-#{size}.png")
      _ -> Image.url {image, podcast}, size
    end
  end

  def login_url(conn) do
    auth_path(conn, :login, next: conn.request_path)
  end

  def paginate(%Plug.Conn{} = conn, page, fun) do
    pagination_html = PaginationView.render("pagination.html", conn: conn, page: page)
    html_escape [pagination_html, fun.(), pagination_html]
  end

end
