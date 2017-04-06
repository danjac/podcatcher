defmodule Podcatcher.Web.SharedViewTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.SharedView

  test "has_next_page should be false if no other pages" do
    page = %{page_number: 5, total_pages: 5}
    assert not has_next_page(page)
  end

  test "has_next_page should be true if other pages" do
    page = %{page_number: 5, total_pages: 15}
    assert has_next_page(page)
  end

  test "has_previous_page should be false if first page" do
    page = %{page_number: 1, total_pages: 5}
    assert not has_previous_page(page)
  end

  test "has_previous_page should be true if not first page" do
    page = %{page_number: 5, total_pages: 10}
    assert has_previous_page(page)
  end

end
