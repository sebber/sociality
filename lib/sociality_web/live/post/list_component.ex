defmodule SocialityWeb.Post.ListComponent do
  use SocialityWeb, :live_component

  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <%= for post <- @posts do %>
        <%= live_component @socket, Components.Post, id: post.id, post: post, current_user: @current_user %>
      <% end %>
    </div>
    """
  end
end
