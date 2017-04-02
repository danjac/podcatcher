defmodule Podcatcher.Parser.FeedParser do
  import SweetXml, except: [parse: 1]
  use Timex
  # require Logger

  @user_agents [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1)",
  "AppleWebKit/537.36 (KHTML, like Gecko)",
  "Chrome/39.0.2171.95 Safari/537.36",
  ]

  @date_formats ["{RFC1123}", "{RFC1123z}"]

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
        title: ~x"./title/text()"s,
        website: ~x"./link/text()"s,
        description: ~x"./description/text()"s,
        subtitle: ~x"./itunes:subtitle/text()"s,
        explicit: ~x"./itunes:explicit/text()"s |> transform_by(&parse_boolean/1),
        image: ~x"./image/url/text()"s,
      ],
      episodes: [
        ~x"./channel/item"l,
        title: ~x"./title/text()"s,
        link: ~x"./link/text()"s,
        guid: ~x"./guid/text()"s,
        description: ~x"./description/text()"s,
        summary: ~x"./itunes:summary/text()"s,
        subtitle: ~x"./itunes:subtitle/text()"s,
        duration: ~x"./itunes:duration/text()"s,
        explicit: ~x"./itunes:explicit/text()"s |> transform_by(&parse_boolean/1),
        pub_date: ~x"./pubDate/text()"s |> transform_by(&parse_date/1),
        content_url: ~x"./enclosure/@url"s,
        content_type: ~x"./enclosure/@type"s,
        content_length: ~x"./enclosure/@length"s |> transform_by(&parse_integer/1),
      ]
    )
  end

  def parse_categories(values) do
    values |> Enum.uniq |> Enum.map(&to_string/1)
  end

  def parse_boolean(value, match_true \\ "yes") do
    value == match_true
  end

  def parse_integer(value) do
    case Integer.parse(value) do
      {num, _} -> num
      :error -> 0
    end
  end

  def parse_date(value) do
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
