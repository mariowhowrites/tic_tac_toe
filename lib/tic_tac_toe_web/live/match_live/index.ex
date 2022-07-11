defmodule TicTacToeWeb.MatchLive.Index do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Multiplayer
  alias Phoenix.PubSub

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      PubSub.subscribe(TicTacToe.PubSub, "all_matches")
    end

    {:ok,
     socket
     |> assign(:matches, list_matches())
     |> assign(:user_uuid, Map.get(session, "user_uuid"))}
  end

  @impl true
  def handle_info(message, socket) do
    IO.inspect(message)

    {
      :noreply,
      socket
      |> assign(:matches, list_matches())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_patch(socket, socket.assigns.live_action, params)}
  end

  defp apply_patch(socket, :new, _params) do
    {:ok, new_match} = Multiplayer.create_match(%{creator: socket.assigns.user_uuid})

    push_redirect(
      socket,
      to: Routes.match_show_path(socket, :show, new_match)
    )
  end

  defp apply_patch(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Matches")
    |> assign(:match, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    match = Multiplayer.get_match!(id)
    {:ok, _} = Multiplayer.delete_match(match)

    {:noreply, assign(socket, :matches, list_matches())}
  end

  def handle_event("accept", %{"id" => id}, socket) do
    match = Multiplayer.get_match!(id)
    {:ok, match} = Multiplayer.add_match_challenger(match, socket.assigns.user_uuid)

    {:noreply,
      socket
      |> assign(:matches, list_matches())
      |> push_redirect(to: Routes.match_show_path(socket, :show, match))}
  end

  defp list_matches do
    Multiplayer.list_matches()
  end

  defp display_name(:creator, match, user_uuid) do
    case Multiplayer.is_match_creator?(match, user_uuid) do
      true -> "You"
      false -> String.slice(match.creator, 0..5)
    end
  end

  defp display_name(:challenger, match, user_uuid) do
    case match.challenger do
      nil -> "Nobody... yet"
      ^user_uuid -> "You"
      _default -> user_uuid
    end
  end
end
