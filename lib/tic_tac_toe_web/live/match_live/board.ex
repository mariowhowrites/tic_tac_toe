defmodule TicTacToeWeb.MatchLive.Board do
  use TicTacToeWeb, :live_component

  alias TicTacToe.Multiplayer

  # hard coded for now, could make configurable for larger games in the future
  @total_squares 9

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:total_squares, @total_squares)}
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

  def square_classes(index, total_squares) do
    "border-black flex items-center justify-center h-60 w-60 cursor-pointer"
    |> border_classes(index, total_squares)
  end

  @doc """
  Given an index and a max length, we want to determine what CSS border classes we should apply.

  If the squares are in the top row, their index <= 1/3.
  If the squares are in the bottom row, their index >= 2/3
  If the squares are in the left row, rem(index, row_count) === 1
  If the squares are in the right row, rem(index, row_count) === 0
  """
  def border_classes(str, index, max_length) do
    row_count = :math.sqrt(max_length)

    Enum.join(
      [
        str,
        border_top_classes(index, max_length),
        border_right_classes(index, row_count),
        border_bottom_classes(index, max_length),
        border_left_classes(index, row_count)
      ],
      " "
    )
  end

  defp border_top_classes(index, max_length) do
    if index / max_length <= 1 / 3 do
      "border-t-2"
    else
      "border-t"
    end
  end

  defp border_bottom_classes(index, max_length) do
    if index / max_length >= 2 / 3 do
      "border-b-2"
    else
      "border-b"
    end
  end

  defp border_left_classes(index, row_count) do
    if rem(index, trunc(row_count)) === 1 do
      "border-l-2"
    else
      "border-l"
    end
  end

  defp border_right_classes(index, row_count) do
    if rem(index, trunc(row_count)) === 0 do
      "border-r-2"
    else
      "border-r"
    end
  end
end
