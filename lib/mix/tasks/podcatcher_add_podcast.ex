defmodule Mix.Tasks.Podcatcher.AddPodcast do
  use Mix.Task

  @shortdoc "Add a new RSS feed"
  def run([rss_feed]) do
    Mix.Task.run "app.start"
    case Podcatcher.Podcasts.get_or_create_podcast_from_rss_feed(rss_feed) do
      {:ok, true, podcast} -> IO.puts "New podcast #{podcast.title} added"
      {:ok, false, podcast} -> IO.puts "Podcast #{podcast.title} already in database"
      {:error, reason} -> IO.puts "Error: #{reason}"
    end
  end

end
