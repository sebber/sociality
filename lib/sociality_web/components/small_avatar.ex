defmodule SocialityWeb.Components.SmallAvatar do
  use SocialityWeb, :live_component

  def mount(socket) do
    # socket = assign(socket, key: value)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= avatar_thumb(@user, large: false) %>
    """
  end
end
