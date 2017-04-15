defmodule Podcatcher.Web.Plugs.Authenticate do
  import Plug.Conn

  alias Podcatcher.Accounts

  def init(_) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Accounts.get_user!(user_id) ->
        conn
        |> assign(:user, user)
        |> assign(:bookmarks, Enum.map(user.bookmarks, fn(bookmark) -> bookmark.episode_id end))
      true -> assign(conn, :user, nil)
    end
  end

end
