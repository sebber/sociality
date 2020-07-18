defmodule SocialityWeb.Components.Comment do
  use SocialityWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="w-full pt-1 mb-1 flex flex-row">
      <%= live_component @socket, Components.SmallAvatar, user: @comment.author %>
      <div class="flex flex-col flex-grow ">
          <div class="px-4 py-1 bg-gray-200 rounded-full text-sm text-gray-800">
          <%= user_link(@socket, @comment.author) %>
          <%= @comment.content %>
          </div>
          <div class="px-4 text-xs text-gray-600">
          <span class="line-through cursor-pointer">Like</span>
           ·
          <span class="line-through cursor-pointer">Reply</span>
           ·
          <%= time_since(@comment.inserted_at) %>
          </div>
      </div>
    </div>
    """
  end
end
