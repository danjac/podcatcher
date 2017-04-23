defmodule Podcatcher.Web.Admin.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts

  import Podcatcher.Web.URLHelpers, only: [podcast_url: 2]

  plug Podcatcher.Web.Plugs.RequireAuth
  plug Podcatcher.Web.Plugs.RequireAdmin

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"podcast" => %{"url" => ""}}) do
    render conn, "new.html"
  end

  def create(conn, %{"podcast" => %{"url" => url}}) do
    case Podcasts.get_or_create_podcast_from_rss_feed(url) do
      {:ok, true, podcast} ->
        conn
        |> put_flash(:success, "Podcast #{podcast.title} created")
        |> redirect to: podcast_url(conn, podcast)
      {:ok, false, podcast} ->
        conn
        |> put_flash(:warning, "Podcast #{podcast.title} already exists")
        |> render "new.html"
      {:error, _} ->
        conn
        |> put_flash(:warning, "Sorry an error occurred")
        |> render "new.html"
    end
  end

  def create(conn, _params) do
    render conn, "new.html"
  end

  def delete(conn, %{"id" => id}) do
    {:ok, podcast} = Podcasts.get_podcast!(id)
    |> Podcasts.delete_podcast

    conn
    |> put_flash(:warning, "Podcast #{podcast.title} has been deleted!")
    |> redirect(to: podcasts_path(conn, :index))
  end

end
