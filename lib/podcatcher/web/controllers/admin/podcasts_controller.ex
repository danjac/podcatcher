defmodule Podcatcher.Web.Admin.PodcastsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Podcasts

  plug Podcatcher.Web.Plugs.RequireAuth
  plug Podcatcher.Web.Plugs.RequireAdmin

  def index(conn, %{"q" => ""} = params), do: latest_podcasts(conn, params)

  def index(conn, %{"q" => search_term} = params) do
    page = Podcasts.search_podcasts(search_term, params)
    render conn, "index.html", page: page, search_term: search_term
  end


  def index(conn, params), do: latest_podcasts(conn, params)

  defp latest_podcasts(conn, params) do
    page = Podcasts.latest_podcasts(Map.put(params, :page_size, 30))
    render conn, "index.html", page: page, search_term: nil
  end

  def delete_podcast(conn, %{"id" => id}) do
    {:ok, podcast} = Podcasts.get_podcast!(id)
    |> Podcasts.delete_podcast

    conn
    |> put_flash(:warning, "Podcast #{podcast.title} has been deleted!")
    |> redirect to: podcasts_path(conn, :index)
  end

end
