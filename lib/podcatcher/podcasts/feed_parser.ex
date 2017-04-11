defmodule Podcatcher.Podcasts.FeedParser do
  import SweetXml, except: [parse: 1]
  use Timex
  # require Logger

  @user_agents [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1)",
  "AppleWebKit/537.36 (KHTML, like Gecko)",
  "Chrome/39.0.2171.95 Safari/537.36",
  ]

  @date_formats ~w"{RFC1123} {RFC1123z} {RFC822} {RFC822z} {RFC3339} {RFC3339z} {ANSIC} {UNIX}"

  @default_options [
    # follow_redirect: true,
    ssl: [{:versions, [:'tlsv1.2']}]
  ]

  @redirect_status_codes [301, 302, 307]

  def fetch_and_parse(url, options \\ @default_options) do
    # Logger.info "FETCHING #{url}"
    with response = HTTPoison.get(url, [{"User-agent", Enum.join(@user_agents, ", ")}], options) do
      handle_response(url, response)
    end
  end

  defp handle_response(_url, {:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    # Logger.info "PARSING #{url}"
    parse(body)
  end

  defp handle_response(url, {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}}) do
    if Enum.member?(@redirect_status_codes, status_code) do
      redirect(url, headers)
    else
      {:error, "Invalid status code for url #{url} : #{status_code}"}
    end
  end

  defp handle_response(_url, {:error, reason}) do
    {:error, reason}
  end

  defp redirect(url, headers) do
    target = headers |> Enum.into(%{}) |> Map.get("Location")
    case target do
      nil -> {:error, "No location found in URL"}
      ^url -> {:error, "Repeats same URL"}
      _ -> fetch_and_parse(target)
    end
  end

  def parse(xml_string) do
    xml_string |> xmap(
      categories: ~x"//itunes:category/@text"l |> transform_by(&parse_categories/1),
      podcast: [
        ~x"./channel",
        title: ~x"./title/text()"s |> transform_by(&String.trim/1),
        website: ~x"./link/text()"s |> transform_by(&String.trim/1),
        last_build_date: ~x"./lastBuildDate/text()"s |> transform_by(&parse_date/1),
        pub_date: ~x"./pubDate/text()"s |> transform_by(&parse_date/1),
        description: ~x"./description/text()"s |> transform_by(&String.trim/1),
        subtitle: ~x"./itunes:subtitle/text()"s |> transform_by(&String.trim/1),
        explicit: ~x"./itunes:explicit/text()"s |> transform_by(&parse_boolean/1),
        rss_image: ~x"./image/url/text()"l |> transform_by(&to_string/1),
        itunes_image: ~x"./itunes:image/@href"l |> transform_by(&to_string/1),
      ],
      episodes: [
        ~x"./channel/item"l,
        title: ~x"./title/text()"s |> transform_by(&String.trim/1),
        link: ~x"./link/text()"s |> transform_by(&String.trim/1),
        guid: ~x"./guid/text()"s |> transform_by(&String.trim/1),
        description: ~x"./description/text()"s |> transform_by(&String.trim/1),
        summary: ~x"./itunes:summary/text()"s |> transform_by(&String.trim/1),
        subtitle: ~x"./itunes:subtitle/text()"s |> transform_by(&String.trim/1),
        duration: ~x"./itunes:duration/text()"s |> transform_by(&String.trim/1),
        explicit: ~x"./itunes:explicit/text()"s |> transform_by(&parse_boolean/1),
        pub_date: ~x"./pubDate/text()"s |> transform_by(&parse_date/1),
        content_url: ~x"./enclosure/@url[1]"s |> transform_by(&String.trim/1),
        content_type: ~x"./enclosure/@type[1]"s |> transform_by(&String.trim/1),
        content_length: ~x"./enclosure/@length[1]"s |> transform_by(&parse_integer/1),
      ]
    )
    |> filter_episodes
    |> add_images
    |> fix_last_build_date
  end

  defp filter_episodes(feed) do
    Map.put(feed, :episodes, Enum.filter(feed.episodes, &valid_episode?/1))
  end

  defp valid_episode?(%{pub_date: pub_date}) when is_nil(pub_date), do: false

  defp valid_episode?(%{content_url: content_url}) when content_url == "", do: false

  defp valid_episode?(%{guid: guid}) when guid == "", do: false

  defp valid_episode?(%{}), do: true

  defp fix_last_build_date(%{podcast: podcast, episodes: episodes} = feed) do
    # find most recent episode
    last_build_date =
    episodes
    |> Enum.map(fn(episode) -> episode.pub_date end)
    |> Enum.max_by(&DateTime.to_unix/1, fn -> nil end)
    %{ feed | podcast: %{ podcast | last_build_date: last_build_date } }
  end

  defp add_images(%{podcast: %{rss_image: rss_image, itunes_image: itunes_image}} = feed) do
    feed |> Map.put(:images, [rss_image, itunes_image])
  end

  defp parse_categories(values) do
    values
    |> Enum.uniq
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.replace(&1, "&amp;", "&"))
  end

  def parse_boolean(value, match_true \\ "yes") do
    value == match_true
  end

  defp parse_integer(value) do
    case Integer.parse(value) do
      {num, _} -> num
      :error -> 0
    end
  end

  defp parse_date(value) do
    do_parse_date(@date_formats, value)
  end

  defp do_parse_date([], _), do: nil

  defp do_parse_date([format | tail], value) do
    case Timex.parse(value, format) do
      # convert to UTC for database compatibility
      {:ok, datetime} -> Timezone.convert(datetime, "Etc/UTC")
      {:error, _} -> do_parse_date(tail, value)
    end
  end

end
