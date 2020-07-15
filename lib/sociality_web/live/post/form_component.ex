defmodule SocialityWeb.Post.FormComponent do
  use Phoenix.LiveComponent

  alias Sociality.Posts
  alias Sociality.Posts.Post

  use Phoenix.HTML

  def mount(socket) do
    {:ok, assign(socket, changeset: Posts.change_post(%Post{}))}
  end

  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#", [id: @id, phx_target: "##{@id}", phx_submit: "create-post"] %>
      <div class="mb-4 flex flex-col bg-white border border-gray-300 rounded text-gray-900"">
        <div class="bg-gray-200 py-1 px-4 text-gray-900 text-sm">
        Create post
        </div>

        <%= textarea f, :content, rows: 4, placeholder: "What are you thinking about?", class: "px-4 py-2" %>

        <%= if @changeset.action do %>
        <div class="alert alert-danger">
            <p>Oops, something went wrong! Please check the errors below.</p>
        </div>
        <% end %>

        <div class="m-2 pt-2 flex flex-row flex-wrap justify-end border-t border-gray-200">
        <%= submit "Save", class: "px-4 py-1 bg-indigo-800 rounded-full text-xs text-gray-400 border border-indigo-400 hover:bg-indigo-700 hover:text-gray-200" %>
        </div>
      </div>
    </form>
    """
  end

  def handle_event("create-post", %{"post" => params}, socket) do
    socket.assigns.user
    |> Posts.create_post(params)

    {:noreply, socket}
  end
end
