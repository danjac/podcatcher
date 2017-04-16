defmodule Podcatcher.Web.SubscriptionsController do
  use Podcatcher.Web, :controller

  alias Podcatcher.Subscriptions
  alias Podcatcher.Podcasts

  plug Podcatcher.Web.Plugs.RequireAuth

  def index(conn, params) do
    page = Subscriptions.subscriptions_for_user(conn.assigns[:user], params)
    render conn, "index.html", page: page
  end

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

end

