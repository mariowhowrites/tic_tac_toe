defmodule TicTacToeWeb.MatchLive.Board do
  use TicTacToeWeb, :live_component

  alias TicTacToe.Multiplayer

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{match: match, user: user}, socket) do
    {
      :ok,
      socket
      |> assign(:match, match)
      |> assign(:user, user)
    }
  end

  @impl true
  def handle_event("update_game_value", %{"index" => index}, socket)
      when socket.assigns.match.creator === socket.assigns.user do
    {index, _} = Integer.parse(index)

    new_match =
      Multiplayer.update_match_state(
        socket.assigns.match,
        :creator,
        index
      )

    {
      :noreply,
      assign(
        socket,
        :match,
        new_match
      )
    }
  end

  @impl true
  def handle_event("update_game_value", %{"index" => index}, socket)
      when socket.assigns.match.challenger === socket.assigns.user do
    {index, _} = Integer.parse(index)


    new_match =
      Multiplayer.update_match_state(
        socket.assigns.match,
        :challenger,
        index
      )

    {
      :noreply,
      assign(
        socket,
        :match,
        new_match
      )
    }
  end

  # when user is neither creator nor challenger
  def handle_event("update_game_value", _args, socket) do
    {
      :noreply,
      socket
    }
  end

  def get_square_value(match, index) do
    TicTacToe.Multiplayer.Engine.get_value(match, index)
  end
end
