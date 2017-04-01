defmodule Podcatcher.Podcasts.Podcast do
  use Ecto.Schema

  schema "podcasts_podcasts" do
    field :copyright, :string
    field :description, :string
    field :email, :string
    field :explicit, :boolean, default: false
    field :image, :string
    field :owner, :string
    field :rss_feed, :string
    field :subtitle, :string
    field :title, :string
    field :website, :string

    timestamps()
  end
end
