defmodule SocialityWeb.Components.Post do
  use SocialityWeb, :live_component

  alias Sociality.Accounts.User
  alias Sociality.Posts
  alias Sociality.Posts.Post
  alias Sociality.Comments
  alias Sociality.Comments.Comment

  def mount(socket) do
    socket =
      assign(socket,
        comments_changeset: Comments.change_comment(%Comment{})
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="mb-4 flex flex-col bg-white border border-gray-300 rounded text-gray-900">
      <div class="p-2 flex flex-row justify-between"> <%# Post Header / Author %>
        <%= live_component @socket, Components.LargeAvatar, user: @post.author %>
        <div class="flex-grow px-4">
          <div class=""><%= user_link(@socket, @post.author) %></div>
          <div class="text-gray-600 text-xs"><%= time_since(@post.inserted_at) %></div>
        </div>
        <div class="">
          <%= link "x", to: "#",
              id: "delete-post-#{@post.id}",
              class: "text-red-600",
              phx_target: @myself,
              phx_click: "delete-post",
              phx_value_id: @post.id %>
        </div>
      </div>

      <div class="p-2 ">
          <%= @post.content %>
      </div>

      <div class="mx-2 mb-2 pt-2 flex flex-row border-t border-gray-200">
        <%= if user_likes_post(@current_user, @post) do %>
          <%= link "Unlike", to: "#",
                id: "unlike-post-#{@post.id}",
                class: "text-indigo-600",
                phx_target: @myself,
                phx_click: "unlike-post",
                phx_value_id: @post.id %>
        <% else %>
          <%= link "Like", to: "#",
                id: "like-post-#{@post.id}",
                class: "text-indigo-600",
                phx_target: @myself,
                phx_click: "like-post",
                phx_value_id: @post.id %>

        <% end %>
        (<%= count_likes(@post) %>)
      </div>

      <%= if Enum.count(@post.comments) > 0 do %>
        <div class="mx-2 mb-2 pt-2 flex flex-col border-t border-gray-200">
            <%= for comment <- @post.comments do %>
              <%= live_component @socket, Components.Comment, post: @post, comment: comment %>
            <% end %>
        </div>
      <% end %>

      <%= cf = form_for @comments_changeset, "#", [id: "comments-form-#{@post.id}", phx_target: "#comments-form-#{@post.id}", phx_submit: "post-comment"] %>
        <%= hidden_input :post, :id, [value: @post.id] %>

        <div class="m-2 pt-2 flex flex-row flex-wrap border-t border-gray-200">
          <div class="w-8 h-8 mr-4 bg-gray-600 rounded-full"></div>

          <div class="flex flex-row min-h-8 px-4 pt-1 mr-4 bg-gray-200 rounded-full text-sm text-gray-800 border border-gray-400 flex-grow placeholder-gray-900">
            <%= textarea cf, :content, [rows: 1, placeholder: "Comment...", class: "flex-grow h-full w-full bg-gray-200 text-sm text-gray-800 placeholder-gray-900"] %>
          </div>

          <%= submit "Save", class: "px-4 py-1 bg-gray-200 rounded-full text-xs text-gray-800 border border-gray-400 hover:bg-gray-100" %>

          <%= if @comments_changeset.action do %>
            <div class="alert alert-danger">
                <p>Oops, something went wrong! Please check the errors below.</p>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  defp user_likes_post(%{id: user_id} = _current_user, post) do
    case Enum.find(post.reactions, &(&1.user_id == user_id)) do
      nil -> false
      _ -> true
    end
  end

  defp count_likes(post) do
    Enum.count(post.reactions)
  end

  def handle_event("delete-post", %{"id" => id}, socket) do
    with %Post{} = post <- Posts.get_post!(id, %{author: true}),
         true <- post.author.id == socket.assigns.current_user.id do
      {:ok, _post} = Posts.delete_post(post)
    end

    {:noreply, socket}
  end

  def handle_event("like-post", %{"id" => post_id}, socket) do
    with %User{} = user <- socket.assigns.current_user,
         %Post{} = post <- Posts.get_post!(post_id) do
      Posts.like_post(user, post)
    else
      reason ->
        IO.inspect(reason)
    end

    {:noreply, socket}
  end

  def handle_event("unlike-post", %{"id" => post_id}, socket) do
    with %User{} = user <- socket.assigns.current_user,
         %Post{} = post <- Posts.get_post!(post_id) do
      Posts.unlike_post(user, post)
    else
      reason ->
        IO.inspect(reason)
    end

    {:noreply, socket}
  end

  def handle_event(
        "post-comment",
        %{"post" => %{"id" => post_id}, "comment" => %{"content" => comment}},
        socket
      ) do
    post = Posts.get_post!(post_id)

    Posts.add_comment(socket.assigns.current_user, post, comment)

    {:noreply, socket}
  end
end
