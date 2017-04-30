# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Podcatcher.Repo.insert!(%Podcatcher.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


path = Application.app_dir(:podcatcher, "priv/repo")
filename = Path.join(path, "urls.txt")

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
    {:error, reason} -> IO.puts "Error: #{inspect reason}"
  end
end


