defmodule Podcatcher.Web.FormatHelpersTest do
  use Podcatcher.Web.ConnCase, async: true

  import Podcatcher.Web.FormatHelpers

  test "pluralize with default plural ending" do
    assert pluralize(2, "result") == "results"
  end

  test "pluralize singular with default plural ending" do
    assert pluralize(1, "result") == "result"
  end

  test "pluralize plural" do
    assert pluralize(2, "category", "categories") == "categories"
  end

  test "pluralize singular" do
    assert pluralize(1, "category", "categories") == "category"
  end

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

  test "keywords/1 when nil" do
    assert keywords(nil) == []
  end

  test "keywords/1 with mixed cases" do
    assert keywords("Best, of , the, Rest") == ["best", "of", "the", "rest"]
  end

  test "keywords/1 if just spaces" do
    assert keywords("Best of the Rest") == ["best", "of", "the", "rest"]
  end

end
