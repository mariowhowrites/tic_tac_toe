defmodule TicTacToe.Multiplayer.Engine do
  @creator_symbol "O"
  @challenger_symbol "X"

  @winning_combos [
    # three horizontal
    [3, 2, 1],
    [6, 5, 4],
    [9, 8, 7],

    # three vertical
    [7, 4, 1],
    [9, 6, 3],
    [8, 5, 2],

    # two diagonal
    [9, 5, 1],
    [7, 5, 3]
  ]

  def new_match_state do
    %{
      @creator_symbol => [],
      @challenger_symbol => []
    }
  end

  def update_match_state(match, role, index) do
    player_to_update =
      case role do
        :creator ->
          @creator_symbol

        :challenger ->
          @challenger_symbol
      end

    update_state(match, player_to_update, index)
  end

  defp update_state(match, player_to_update, index) do
    cond do
      is_index_filled_already?(match, index) ->
        IO.inspect "index filled already"
        match.match_state

      is_out_of_turn?(match, player_to_update) ->
        IO.inspect "is out of turn"
        match.match_state

      true ->
        {_, new_match_state} =
          Map.get_and_update(match.match_state, player_to_update, fn current_list ->
            {current_list, [index | current_list]}
          end)

        new_match_state
    end
  end

  defp is_index_filled_already?(match, index) do
    Enum.any?(match.match_state, fn {_player, squares} -> index in squares end)
  end

  defp is_out_of_turn?(match, player_to_update) do
    (player_to_update === @creator_symbol and match_status(match) !== :creator_turn)
    or (player_to_update === @challenger_symbol and match_status(match) not in [:challenger_turn, :accepted])
  end

  def match_status(match) do
    creator_squares = match.match_state[@creator_symbol]
    challenger_squares = match.match_state[@challenger_symbol]

    cond do
      match.challenger === nil ->
        :open

      match.challenger !== nil && length(challenger_squares) === 0 ->
        :accepted

      is_winning?(challenger_squares) ->
        :challenger_win

      is_winning?(creator_squares) ->
        :creator_win

      # if we're here, nobody has won yet
      is_draw?(match.match_state) ->
        :draw

      # if we're here, game isn't over yet
      length(challenger_squares) == length(creator_squares) ->
        :challenger_turn

      true ->
        :creator_turn
    end
  end

  def is_winning?(squares) do
    Enum.any?(@winning_combos, fn combo -> Enum.all?(combo, &(&1 in squares)) end)
  end

  def is_draw?(match_state) do
    length(match_state[@creator_symbol]) + length(match_state[@challenger_symbol]) ==
      9
  end

  def get_value(match, index) do
    cond do
      index in match.match_state[@creator_symbol] -> @creator_symbol
      index in match.match_state[@challenger_symbol] -> @challenger_symbol
      true -> ""
    end
  end
end
