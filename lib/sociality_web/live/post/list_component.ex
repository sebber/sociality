defmodule SocialityWeb.Post.ListComponent do
  use SocialityWeb, :live_component

  alias Sociality.Posts
  alias Sociality.Posts.Post
  alias Sociality.Comments
  alias Sociality.Comments.Comment

  use Phoenix.HTML
  import SocialityWeb.Helpers

  def mount(socket) do
    socket =
      assign(socket,
        comments_changeset: Comments.change_comment(%Comment{})
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <%= for post <- @posts do %>
      <div id="<%= "#{@id}-post-#{post.id}" %>" class="mb-4 flex flex-col bg-white border border-gray-300 rounded text-gray-900">
          <div class="p-2 flex flex-row justify-between"> <%# Post Header / Author %>
              <%= avatar_thumb(post.author, large: true) %>
              <div class="flex-grow px-4">
                  <div class=""><%= user_link(@socket, post.author) %></div>
                  <div class="text-gray-600 text-xs"><%= time_since(post.inserted_at) %></div>
              </div>
              <div class="">
                  <%= if post.author.id == @current_user.id do %>
                  <%= link "x", to: "#",
                      id: "delete-post-#{post.id}",
                      class: "text-red-600",
                      phx_target: "##{@id}-post-#{post.id}",
                      phx_click: "delete-post",
                      phx_value_id: post.id %>
                  <% end %>
              </div>
          </div>
          <div class="p-2 ">
              <%= post.content %>
          </div>

          <%= if Enum.count(post.comments) > 0 do %>
          <div class="mx-2 mb-2 pt-2 flex flex-col border-t border-gray-200">
              <%= for comment <- post.comments do %>
              <div class="w-full pt-1 mb-1 flex flex-row">
              <%= avatar_thumb(comment.author, large: false) %>
              <div class="flex flex-col flex-grow ">
                  <div class="px-4 py-1 bg-gray-200 rounded-full text-sm text-gray-800">
                  <%= user_link(@socket, comment.author) %>
                  <%= comment.content %>
                  </div>
                  <div class="px-4 text-xs text-gray-600">
                  <span class="line-through cursor-pointer">Like</span> · <span class="line-through cursor-pointer">Reply</span> · <%= time_since(comment.inserted_at) %>
                  </div>
              </div>
              </div>
              <% end %>
          </div>
          <% end %>

          <%= cf = form_for @comments_changeset, "#", [id: "comments-form-#{post.id}", phx_target: "#comments-form-#{post.id}", phx_submit: "post-comment"] %>
          <%= hidden_input :post, :id, [value: post.id] %>

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
      <% end %>
    </div>
    """
  end

  def handle_event("delete-post", %{"id" => id}, socket) do
    with %Post{} = post <- Posts.get_post!(id, %{author: true}),
         true <- post.author.id == socket.assigns.current_user.id do
      {:ok, _post} = Posts.delete_post(post)
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
