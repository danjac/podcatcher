defmodule Podcatcher.Web.SubscriptionsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Subscriptions
  alias Podcatcher.Podcasts

  plug Podcatcher.Web.Plugs.RequireAuth

  def index(conn, %{"q" => ""} = params), do: list_subscriptions(conn, params)

  def index(conn, %{"q" => search_term} = params) do
    page = Subscriptions.search_subscriptions_for_user(conn.assigns[:user], search_term, params)
    podcasts = Enum.map(page.entries, &(&1.podcast))
    render conn, "index.html", podcasts: podcasts, page: page, search_term: search_term, page_title: "My podcasts"
  end

  def index(conn, params), do: list_subscriptions(conn, params)

  def subscribe(conn, %{"id" => podcast_id}) do
    podcast = Podcasts.get_podcast!(podcast_id)
    Subscriptions.create_subscription(conn.assigns[:user], podcast)
    send_resp(conn, :created, "Subscribed")
  end

  def unsubscribe(conn, %{"id" => podcast_id}) do
    podcast = Podcasts.get_podcast!(podcast_id)
    Subscriptions.delete_subscription(conn.assigns[:user], podcast)
    send_resp(conn, :ok, "Unsubscribed")
  end

  defp list_subscriptions(conn, params) do
    page = Subscriptions.subscriptions_for_user(conn.assigns[:user], params)
    podcasts = Enum.map(page.entries, &(&1.podcast))
    render conn, "index.html", podcasts: podcasts, page: page, page_title: "My podcasts"
  end

end

