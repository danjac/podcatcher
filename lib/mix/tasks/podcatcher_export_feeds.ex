defmodule Mix.Tasks.Podcatcher.ExportFeeds do
  use Mix.Task

  alias Podcatcher.Podcasts
  import Phoenix.HTML, only: [html_escape: 1]

  @switches [format: :string]

  @shortdoc "Exports all feeds to CSV or OPML"
  def run(args) do

    Mix.Task.run "app.start"

    {opts, [filename], _} = OptionParser.parse(args, switches: @switches)

    podcasts = Podcasts.list_podcasts()

    output = case opts[:format] do
      "opml" -> to_opml(podcasts)
      _ -> to_text(podcasts)
    end

    with file = File.open!(filename, [:write]) do
      IO.binwrite file, output
      File.close file
    end

  end

  defp to_text(podcasts) do
    podcasts
    |> Enum.map(&(&1.rss_feed))
    |> Enum.join("\n")
  end

  defp to_opml(podcasts) do
    outlines =
      podcasts
      |> Enum.map(fn(p) ->
        {:safe, title} = html_escape(p.title)
        "<outline text=\"#{title}\" title=\"#{title}\" type=\"rss\" xmlUrl=\"#{p.rss_feed}\" />"
      end)
      |> Enum.join("\n")

    """
    <opml version="1.0">
    <head>
      <title>Podbaby feeds</title>
      </head>
    </head>
    <body>
    #{outlines}
    </body>
    </opml>
    """
  end

end
