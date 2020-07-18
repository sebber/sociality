defmodule SocialityWeb.UserView do
  use SocialityWeb, :view
  import SocialityWeb.Helpers

  def user_routes(conn, user) do
    [
      {user_url(conn, user), "Profile"},
      {Routes.user_settings_path(conn, :edit), "Settings"}
    ]
  end

  def current_path(%Plug.Conn{} = conn) do
    Phoenix.Controller.current_path(conn)
  end

  def current_path(%Phoenix.LiveView.Socket{} = _socket) do
    ""
  end
end
