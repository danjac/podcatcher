defmodule Podcatcher.Web.PaginationView do
  use Podcatcher.Web, :view

  @page_param "page"
  @delta 2

  def pagination_links(%Plug.Conn{} = conn, page) do

    left = page.page_number - @delta
    right = page.page_number + @delta + 1

   {_, pages} = Enum.filter(1..page.total_pages, fn(n) ->
      cond do
        n == 1 -> true
        n == page.total_pages -> true
        n >= right -> false
        n >= left -> true
        true -> false
      end
    end)
    |> Enum.reduce({0, []}, fn(n, {last, pages}) ->

      info = page_info(conn, page.page_number, n)
      result = case n - last do

        @delta -> [page_info(conn, page.page_number, last + 1), info]
        1 -> [info]
        _ -> [:ellipsis, info]

      end

      {n, pages ++ result}
    end)

    pages

  end

  defp page_info(_conn, current, num) when current == num, do: %{ current: true, number: num }

  defp page_info(conn, _current, num), do: %{
    current: false,
    url: replace_page_param(conn, num),
    number: num,
  }

  def next_page_url(%Plug.Conn{} = conn, page) do
    replace_page_param(conn, page.page_number + 1)
  end

  def previous_page_url(%Plug.Conn{} = conn, page) do
    replace_page_param(conn, page.page_number - 1)
  end

  def has_previous_page(page) do
    page.page_number > 1
  end

  def has_next_page(page) do
    page.page_number < page.total_pages
  end

  defp replace_page_param(%Plug.Conn{} = conn, new_page_number) do
    params = conn.query_params
    |> Map.put(@page_param, new_page_number)
    |> URI.encode_query
    "#{conn.request_path}?#{params}"
  end

end
