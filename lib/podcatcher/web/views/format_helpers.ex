defmodule Podcatcher.Web.FormatHelpers do

  import Phoenix.HTML, only: [raw: 1]

  use Timex

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

  def markdown(nil), do: ""
  def markdown(""), do: ""

  def markdown(content) do
    content
    |> String.trim
    |> HtmlSanitizeEx.markdown_html
    |> raw
  end

  def strip_tags(nil), do: ""
  def strip_tags(""), do: ""

  def strip_tags(content) do
    content
    |> String.trim
    |> HtmlSanitizeEx.strip_tags
    |> raw
  end

  def pluralize(count, singular), do: pluralize(count, singular, singular <> "s")
  def pluralize(count, singular, _plural) when count == 1, do: singular
  def pluralize(_count, _singular, plural), do: plural

  def keywords(source) when is_nil(source) or source == "", do: []

  def keywords(source) do
    source
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.downcase/1)
    |> Enum.uniq
  end

end

