defmodule SocialityWeb.DashboardLive do
  use SocialityWeb, :live_view
  alias Sociality.Posts

  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    if connected?(socket), do: Sociality.Posts.subscribe()

    socket =
      assign(socket,
        posts: Posts.list_posts(%{author: true, reactions: true, comments: %{author: true}})
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="mx-auto" style="max-width: 640px">
      <%= live_component @socket, SocialityWeb.Post.FormComponent, id: :form, user: @current_user %>
      <%= live_component @socket, SocialityWeb.Post.ListComponent, id: :dashboard_list, current_user: @current_user, posts: @posts %>
    </div>
    """
  end

  def handle_info({Posts, [:posts | _], _post}, socket) do
    posts = Posts.list_posts(%{author: true, reactions: true, comments: %{author: true}})
    socket = assign(socket, posts: posts)
    {:noreply, socket}
  end
end
