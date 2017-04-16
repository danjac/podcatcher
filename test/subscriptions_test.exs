defmodule Podcatcher.SubscriptionsTest do
  use Podcatcher.DataCase

  alias Podcatcher.Subscriptions

  import Podcatcher.Fixtures

  test "subscriptions_for_user/1 gets subscriptions" do

    user = fixture(:user)
    podcast = fixture(:podcast)

    {:ok, sub} = Subscriptions.create_subscription(user, podcast)
    page = Subscriptions.subscriptions_for_user(user)
    [first | _] = page.entries
    assert first.id == sub.id

  end

  test "create_subscription/2 inserts new subscription" do

    user = fixture(:user)
    podcast = fixture(:podcast)

    {:ok, sub} = Subscriptions.create_subscription(user, podcast)
    assert sub.user_id == user.id
    assert sub.podcast_id == podcast.id

  end

  test "delete_subscription/2 deletes subscription" do
    user = fixture(:user)
    podcast = fixture(:podcast)

    Subscriptions.create_subscription(user, podcast)
    Subscriptions.delete_subscription(user, podcast)

    page = Subscriptions.subscriptions_for_user(user)
    assert page.total_entries == 0

  end

end
