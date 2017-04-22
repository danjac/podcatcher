defmodule Podcatcher.Emails do
  use Bamboo.Phoenix, view: Podcatcher.Web.EmailView

  alias Podcatcher.Accounts.User

  @default_sender "support@podbaby.me"

  def reset_password_email(conn, user, token) do
    new_email(
      to: user.email,
      from: @default_sender,
      subject: "Reset your password",
    )
    |> render("recover_password.text", conn: conn, user: user, token: token)
  end
end
