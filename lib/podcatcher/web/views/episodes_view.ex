defmodule Podcatcher.Web.EpisodesView do
  use Podcatcher.Web, :view
  use Timex

  alias Podcatcher.Podcasts.Podcast
  alias Podcatcher.Podcasts.Image

  # this will be moved to PodcastsView later
  def podcast_image(conn, %Podcast{image: image} = podcast, size) do
    case image do
      nil -> static_path(conn, "/images/rss-#{size}.png")
      _ -> Image.url {image, podcast}, size
    end
  end

  def truncate(s, max_length)  do
    cond do
      String.length(s) < max_length -> s
      true -> "#{s |> String.slice(0, (max_length - 3))}..."
    end
  end

  def format_date(nil), do: ""

  def format_date(dt) do
    Timex.format! dt, "{Mfull} {D}, {YYYY}"
  end

  def audio_ext(""), do: ""
  def audio_ext(nil), do: ""

  def audio_ext(url) do
    ext = URI.parse(url).path
    |> Path.extname
    String.slice(ext, 1, String.length(ext))
  end

  def markdown(content) do
    content
    |> Earmark.as_html!
    |> HtmlSanitizeEx.basic_html
    |> raw
  end
end
