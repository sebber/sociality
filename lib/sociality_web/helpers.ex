defmodule SocialityWeb.Helpers do
  import Phoenix.LiveView
  use Phoenix.HTML
  use Timex
  alias SocialityWeb.Router.Helpers, as: Routes

  def user_link(conn, user), do: user_link(conn, user, "")

  def user_link(conn, user, class) do
    link(
      user.name,
      to: user_url(conn, user),
      class: "text-blue-600 text-bold mr-2 #{class}"
    )
  end

  def user_url(conn, user) do
    Routes.live_path(conn, SocialityWeb.Users.ProfileLive, user.id)
  end

  def count_comments(post) do
    Enum.count(post.comments)
  end

  def time_since(time) do
    case Timex.format(time, "{relative}", :relative) do
      {:ok, relative_time} -> relative_time
      _ -> "dunno when this shit was written"
    end
  end

  def avatar_thumb(user, opts \\ []) do
    default = [user: user, large: false]
    options = Keyword.merge(default, opts)

    case options[:large] do
      true -> SocialityWeb.UserView.render("_thumb_large.html", options)
      _ -> SocialityWeb.UserView.render("_thumb_small.html", options)
    end
  end

  def assign_defaults(socket, %{"user_token" => user_token}) do
    socket =
      assign_new(socket, :current_user, fn ->
        Sociality.Accounts.get_user_by_session_token(user_token)
      end)

    if socket.assigns.current_user do
      socket
    else
      redirect(socket, to: "/login")
    end
  end
end
