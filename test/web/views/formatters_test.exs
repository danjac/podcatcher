defmodule Podcatcher.Web.FormattersTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.Formatters

  test "truncate/2 should just return string if length less than max_length" do
    assert truncate("hello world", 30) == "hello world"
  end

  test "truncate/2 should just append ellipsis if longer than max_length" do
    assert truncate("hello world", 10) == "hello w..."
  end

  test "format_date/1 if nil should just return an empty string" do
    assert format_date(nil) == ""
  end

  test "format_date/1 should format a date" do
    assert format_date(~N[2016-12-25 10:00:07]) == "December 25, 2016"
  end

end
