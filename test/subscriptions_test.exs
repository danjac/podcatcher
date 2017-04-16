defmodule Podcatcher.SubscriptionsTest do
  use Podcatcher.DataCase

  alias Podcatcher.Subscriptions
  alias Podcatcher.Subscriptions.Subscription

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:subscription, attrs \\ @create_attrs) do
    {:ok, subscription} = Subscriptions.create_subscription(attrs)
    subscription
  end

  test "list_subscriptions/1 returns all subscriptions" do
    subscription = fixture(:subscription)
    assert Subscriptions.list_subscriptions() == [subscription]
  end

  test "get_subscription! returns the subscription with given id" do
    subscription = fixture(:subscription)
    assert Subscriptions.get_subscription!(subscription.id) == subscription
  end

  test "create_subscription/1 with valid data creates a subscription" do
    assert {:ok, %Subscription{} = subscription} = Subscriptions.create_subscription(@create_attrs)
  end

  test "create_subscription/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription(@invalid_attrs)
  end

  test "update_subscription/2 with valid data updates the subscription" do
    subscription = fixture(:subscription)
    assert {:ok, subscription} = Subscriptions.update_subscription(subscription, @update_attrs)
    assert %Subscription{} = subscription
  end

  test "update_subscription/2 with invalid data returns error changeset" do
    subscription = fixture(:subscription)
    assert {:error, %Ecto.Changeset{}} = Subscriptions.update_subscription(subscription, @invalid_attrs)
    assert subscription == Subscriptions.get_subscription!(subscription.id)
  end

  test "delete_subscription/1 deletes the subscription" do
    subscription = fixture(:subscription)
    assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)
    assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription!(subscription.id) end
  end

  test "change_subscription/1 returns a subscription changeset" do
    subscription = fixture(:subscription)
    assert %Ecto.Changeset{} = Subscriptions.change_subscription(subscription)
  end
end
