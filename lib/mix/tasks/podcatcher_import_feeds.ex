defmodule Mix.Tasks.Podcatcher.ImportFeeds do
  use Mix.Task

  @shortdoc "Import RSS feeds from text file"
  def run([filename]) do
    Mix.Task.run "app.start"

    feeds =
     filename
      |> File.read!
      |> String.split("\n")
      |> Enum.map(&(String.trim(&1)))
      |> Enum.reject(&(&1 == ""))

    for feed <- feeds do
      case Podcatcher.Podcasts.get_or_create_podcast_from_rss_feed(feed) do
        {:ok, true, podcast} -> IO.puts "New podcast #{podcast.title} added"
        {:ok, false, podcast} -> IO.puts "Podcast #{podcast.title} already in database"
        {:error, reason} -> IO.puts "Error: #{reason}"
      end
    end

  end

end
