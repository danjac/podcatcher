defmodule Podcatcher.Web.SharedView do
  use Podcatcher.Web, :view

  def replace_page_param(conn, new_page_number) do
    params = conn.query_params
    |> Map.put("page", new_page_number)
    |> URI.encode_query
    "#{conn.request_path}?#{params}"
  end

end
