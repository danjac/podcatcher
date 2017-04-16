defmodule Podcatcher.Subscriptions do
  @moduledoc """
  The boundary for the Subscriptions system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Podcatcher.Repo

  alias Podcatcher.Subscriptions.Subscription
  alias Podcatcher.Podcasts.Podcast

  @doc """
  Returns paginated list of subscriptions for a user
  """
  def subscriptions_for_user(user, params \\ []) do
    from(
      s in Subscription,
      join: p in assoc(s, :podcast),
      where: s.user_id == ^user.id,
      order_by: [desc: p.last_build_date],
      preload: [:podcast]
    )
    |> Repo.paginate(params)
  end

  @doc """
  Creates a new subscription
  """
  def create_subscription(user, podcast) do
    %Subscription{user_id: user.id, podcast_id: podcast.id} |> Repo.insert()
  end

  @doc """
  Deletes a subscription
  """
  def delete_subscription(user, podcast) do
    from(Subscription, where: [user_id: ^user.id, podcast_id: ^podcast.id])
    |> Repo.delete_all
  end
end
