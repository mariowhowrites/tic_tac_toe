defmodule TicTacToeWeb.MatchLive.Index do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Multiplayer

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Multiplayer.Match.subscribe_matches()
    end

    {
      :ok,
      socket
      |> assign(:matches, list_matches())
      |> assign(:user, Map.get(session, "current_user"))
    }
  end

  @impl true
  def handle_info(:matches, socket) do
    {
      :noreply,
      socket
      |> assign(:matches, list_matches())
    }
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:ok, new_match} = Multiplayer.create_match(%{creator: socket.assigns.user})

    {:noreply,
     push_redirect(
       socket,
       to: Routes.match_show_path(socket, :show, new_match)
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    match = Multiplayer.get_match!(id)
    {:ok, _} = Multiplayer.delete_match(match)

    {:noreply, assign(socket, :matches, list_matches())}
  end

  def handle_event("accept", %{"id" => id}, socket) do
    match = Multiplayer.get_match!(id)
    {:ok, match} = Multiplayer.add_match_challenger(match, socket.assigns.user)

    {
      :noreply,
      socket
      |> assign(:matches, list_matches())
      |> push_redirect(to: Routes.match_show_path(socket, :show, match))
    }
  end

  defp list_matches do
    Multiplayer.list_non_completed_matches()
  end
end
