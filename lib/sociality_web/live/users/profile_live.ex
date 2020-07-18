defmodule SocialityWeb.Users.ProfileLive do
  use SocialityWeb, :live_view
  alias Sociality.Posts
  alias Sociality.Accounts

  def mount(%{"id" => id}, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> assign_profile(id)

    if connected?(socket), do: Sociality.Posts.subscribe()
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= if @profile_user.id == @current_user.id do %>
      <%= SocialityWeb.UserView.render("_profile_nav.html", conn: @socket, user: @profile_user, current_path: user_url(@socket, @profile_user)) %>
    <% end %>

    <div class="bg-white p-2 border border-gray-300 mb-8 rounded-md">
      <%= if @profile_user.avatar do %>
        <img src="<%= Avatar.url({@profile_user.avatar, @profile_user}) %>">
      <% end %>
      <h1 class="text-xl font-bold">Profile of <%= @profile_user.name %></h1>
    </div>

    <h2 class="bg-white p-2 border border-gray-300 mb-2 rounded-md">Posts written by  <%= @profile_user.name %> </h2>

    <%= live_component @socket, SocialityWeb.Post.ListComponent, id: :profile_posts, current_user: @current_user, posts: @posts %>
    """
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, assign_profile(socket, id)}
  end

  def handle_info({Posts, [:posts | _], _post}, socket) do
    posts =
      Posts.list_posts(%{author: true, comments: %{author: true}}, %{
        author: socket.assigns.user.username
      })

    {:noreply, assign(socket, posts: posts)}
  end

  defp assign_profile(socket, user_id) do
    user = Accounts.get_user!(user_id)

    posts =
      Posts.list_posts(%{author: true, reactions: true, comments: %{author: true}}, %{
        author: user.id
      })

    assign(socket,
      profile_user: user,
      posts: posts
    )
  end
end
