defmodule SocialityWeb.SearchLive do
  use SocialityWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, loading: false, results: [])

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="w-full h-full relative">
      <form phx-change="updated-query">
        <input
          type="text"
          name="query"
          placeholder="Search..."
          autocomplete="off"
          class="w-full px-2 py-1 text-xs bg-white rounded-sm" />
      </form>
      <%= if not @loading and Enum.count(@results) > 0 do %>
        <div class="w-64 bg-white border border-indigo-300 divide-y divide-indigo-100 absolute">
          <%= for item <- @results do %>
            <div class="px-2 py-1 ">
              <%= item.name %>
            </div>
          <% end %>
        </div>
      <% end %>
      <%= if @loading do %>
        <div class="w-64 bg-white border border-indigo-300 divide-y divide-indigo-100 absolute">
          <div class="px-2 py-1 ">Loading...</div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("updated-query", %{"query" => query}, socket) do
    results =
      case String.length(query) >= 3 do
        true ->
          Enum.filter(items(), &String.contains?(&1.name, query))

        _ ->
          []
      end

    socket =
      assign(socket,
        results: results
      )

    {:noreply, socket}
  end

  def items do
    [
      %{name: "Basse"},
      %{name: "Bengt"},
      %{name: "Urban"},
      %{name: "Lars"},
      %{name: "Kalle Bongsson"}
    ]
  end
end
