defmodule Podcatcher.Web.Formatters do

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

  def markdown(content) do
    content
    |> Earmark.as_html!
    |> HtmlSanitizeEx.basic_html
    |> raw
  end

end

