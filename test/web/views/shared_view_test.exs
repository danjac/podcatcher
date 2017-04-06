defmodule Podcatcher.Web.SharedViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.SharedView

  test "has_next_page/1 should be false if no other pages" do
    page = %{page_number: 5, total_pages: 5}
    assert not has_next_page(page)
  end

  test "has_next_page/1 should be true if other pages" do
    page = %{page_number: 5, total_pages: 15}
    assert has_next_page(page)
  end

  test "has_previous_page/1 should be false if first page" do
    page = %{page_number: 1, total_pages: 5}
    assert not has_previous_page(page)
  end

  test "has_previous_page/1 should be true if not first page" do
    page = %{page_number: 5, total_pages: 10}
    assert has_previous_page(page)
  end

  test "next_page_url/2 should return URL with new page param in query string" do
    conn = %Plug.Conn{
      request_path: "/latest/",
      query_params: %{
        "page"=> "1",
      }
    }
    page = %{ page_number: 1 }
    assert next_page_url(conn, page) == "/latest/?page=2"

  end

  test "previous_page_url/2 should return URL with new page param in query string" do
    conn = %Plug.Conn{
      request_path: "/latest/",
      query_params: %{
        "page"=> "2",
      }
    }
    page = %{ page_number: 2 }
    assert previous_page_url(conn, page) == "/latest/?page=1"

  end

  test "pagination_links/2 should return a list of page info maps" do

    {page, total_pages} = page_fixture(1, 20)

    expected = [
      %{current: true, number: 1},
      %{current: false, number: 2, url: "/latest/?page=2"},
      %{current: false, number: 3, url: "/latest/?page=3"},
      :ellipsis,
      %{current: false, number: 20, url: "/latest/?page=20"}
    ]

    assert pagination_links(page, total_pages) == expected

  end

  defp page_fixture(page_number, total_pages) do
    {
      %Plug.Conn{
        request_path: "/latest/",
        query_params: %{
          "page"=> to_string(page_number),
        },
      },
      %{
        page_number: page_number,
        total_pages: total_pages,
      },
    }
  end


end
