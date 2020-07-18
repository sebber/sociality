defmodule SocialityWeb.Users.PostsLive do
  use SocialityWeb, :live_view
  alias Sociality.Posts
  alias Sociality.Posts.Post
  alias Sociality.Comments
  alias Sociality.Comments.Comment

  def mount(_params, %{"user" => user} = session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Sociality.Posts.subscribe()

    socket =
      socket
      |> assign(comments_changeset: Comments.change_comment(%Comment{}))
      |> assign(user: user)
      |> fetch(user)

    {:ok, socket}
  end

  def render(assigns) do
    SocialityWeb.User.PostsView.render("list.html", assigns)
  end

  def handle_info({Posts, [:posts | _], _post}, socket) do
    {:noreply, fetch(socket, socket.assigns.user)}
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

  def handle_event("delete-post", %{"id" => id}, socket) do
    with %Post{} = post <- Posts.get_post!(id, %{author: true}),
         true <- post.author.id == socket.assigns.user.id do
      {:ok, _post} = Posts.delete_post(post)
    end

    {:noreply, socket}
  end

  defp fetch(assigns, user) do
    posts =
      Posts.list_posts(%{author: true, reactions: true, comments: %{author: true}}, %{
        author: user.username
      })

    assign(assigns, posts: posts)
  end
end
