defmodule SocialityWeb.FriendsOnlineLive do
  use Phoenix.LiveView
  alias SocialityWeb.Presence

  @topic "friends_online"

  def mount(_params, %{"current_user" => current_user} = _assigns, socket) do
    Presence.track_presence(
      self(),
      @topic,
      current_user.id,
      default_user_presence_payload(current_user)
    )

    SocialityWeb.Endpoint.subscribe(@topic)

    {:ok,
     assign(socket,
       current_user: current_user,
       users: Presence.list_presences(@topic)
     )}
  end

  def render(assigns) do
    SocialityWeb.FriendsOnlineView.render("list.html", assigns)
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply,
     assign(socket,
       users: Presence.list_presences(@topic)
     )}
  end

  defp default_user_presence_payload(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email
      # email: user.email,
    }
  end
end
