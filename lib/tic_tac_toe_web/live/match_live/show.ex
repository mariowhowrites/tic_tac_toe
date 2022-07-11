defmodule TicTacToeWeb.MatchLive.Show do
  use TicTacToeWeb, :live_view

  alias TicTacToe.Multiplayer

  @impl true
  def mount(%{"id" => id}, session, socket) do
    if connected?(socket) do
      Multiplayer.Match.subscribe_match(id)
    end

    {:ok, socket |> assign(:user_uuid, Map.get(session, "user_uuid"))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:match, Multiplayer.get_match!(id))}
  end

  @impl true
  def handle_info({:match, id}, socket) do
    {
      :noreply,
      socket
      |> assign(:match, Multiplayer.get_match!(id))
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

  defp get_status_text(match) do
    case Multiplayer.Engine.match_status(match.match_state) do
      :challenger_win -> "Challenger Wins"
      :creator_win -> "Creator Wins"
      :challenger_turn -> "Challenger Turn"
      :creator_turn -> "Creator Turn"
      :draw -> "Tie"
    end
  end
end
