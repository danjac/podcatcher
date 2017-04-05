defmodule Podcatcher.Web.EpisodesView do
  use Podcatcher.Web, :view

  import Podcatcher.Web.Formatters
  import Podcatcher.Web.PodcastsView, only: [podcast_image: 3]

  def audio_ext(""), do: ""
  def audio_ext(nil), do: ""

  def audio_ext(url) do
    ext = URI.parse(url).path
    |> Path.extname
    String.slice(ext, 1, String.length(ext))
  end

end
