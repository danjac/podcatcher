defmodule Podcatcher.Web.UserHelpers do

  def bookmarked?(conn, episode) do
    Enum.member?(conn.assigns[:bookmarks], episode.id)
  end

end
