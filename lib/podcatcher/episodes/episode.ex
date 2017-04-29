defmodule Podcatcher.Episodes.Episode do
  use Ecto.Schema

  alias Podcatcher.Podcasts.Podcast

  schema "episodes" do
    field :title, :string
    field :description, :string
    field :author, :string
    field :content_length, :integer
    field :content_type, :string
    field :content_url, :string
    field :duration, :string
    field :explicit, :boolean, default: false
    field :guid, :string
    field :link, :string
    field :pub_date, :naive_datetime
    field :subtitle, :string
    field :summary, :string
    field :keywords, :string

    belongs_to :podcast, Podcast

    timestamps()
  end
end

defimpl Slugify, for: Podcatcher.Episodes.Episode do
  def slugify(episode) do
    case Slugger.slugify_downcase(episode.title) do
      "" -> Slugger.slugify(episode.guid)
      value -> value
    end
  end
end
