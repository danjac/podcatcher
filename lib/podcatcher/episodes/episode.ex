defmodule Podcatcher.Episodes.Episode do
  use Ecto.Schema

  alias Podcatcher.Podcasts.Podcast

  schema "episodes_episodes" do
    field :author, :string
    field :content_length, :integer
    field :content_type, :string
    field :content_url, :string
    field :description, :string
    field :duration, :string
    field :explicit, :boolean, default: false
    field :guid, :string
    field :link, :string
    field :pub_date, :naive_datetime
    field :subtitle, :string
    field :summary, :string
    field :title, :string

    belongs_to :podcast, Podcast

    timestamps()
  end
end
