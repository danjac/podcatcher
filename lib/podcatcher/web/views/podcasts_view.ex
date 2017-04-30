defmodule Podcatcher.Web.PodcastsView do
  use Podcatcher.Web, :view

  alias Podcatcher.Podcasts.Podcast

  def keywords(%Podcast{keywords: nil}), do: []

  def keywords(podcast) do
    podcast.keywords
    |> String.trim
    |> String.split(",")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.downcase/1)
  end

end
