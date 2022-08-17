defmodule TicTacToeWeb.MatchLive.Show do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Multiplayer

  @impl true
  def mount(%{"id" => id}, session, socket) do
    if connected?(socket) do
      Multiplayer.Match.subscribe_match(id)
    end

    {:ok, socket |> assign(:user, Map.get(session, "current_user"))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    match = Multiplayer.get_match!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:match, match)
     |> maybe_push_win_line_event(match)
    }
  end

  @impl true
  def handle_info({:match, id}, socket) do
    match = Multiplayer.get_match!(id)

    {
      :noreply,
      socket
      |> assign(:match, match)
      |> maybe_push_win_line_event(match)
    }
  end

  def handle_info(_params, socket) do
    {
      :noreply,
      socket
    }
  end

  defp page_title(:show), do: "Show Match"
  defp page_title(:edit), do: "Edit Match"

  defp maybe_push_win_line_event(socket, match) do
    case Multiplayer.Engine.match_status(match) in [:challenger_win, :creator_win] do
      true -> push_event(socket, "win_line", %{squares: Multiplayer.Engine.winning_combo(match)})
      false -> socket
    end
  end
end
