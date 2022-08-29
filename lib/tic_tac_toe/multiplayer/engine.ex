defmodule TicTacToe.Multiplayer.Engine do
  @creator_symbol "O"
  @challenger_symbol "X"

  @doc """
  All the potential winning combos in a 3x3 game of tic tac toe.

  For now, we can hard-code these, but if we were ever to add support
  for variable board sizes, we'd probably need some means of automatically deriving these win cons.

  These are then compared against the lists returned by `new_match_state`.
  If any of the lists in `new_match_state` have all of the squares in any winning combo,
  the corresponding player wins the game.

  NOTE: for the moment, it is important that these combos go low -> high, (ex. [1, 2, 3] not [3, 2, 1])
  as the JS algo that draws the winning lines assumes these are low -> high. If the order changes, the JS
  algo will need to change accordingly.
  """
  @winning_combos [
    # three horizontal
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],

    # three vertical
    [1, 4, 7],
    [3, 6, 9],
    [2, 5, 8],

    # two diagonal
    [1, 5, 9],
    [3, 5, 7]
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
        match.match_state

      is_out_of_turn?(match, player_to_update) ->
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
    (player_to_update === @creator_symbol and match_status(match) !== :creator_turn) or
      (player_to_update === @challenger_symbol and
         match_status(match) not in [:challenger_turn, :accepted])
  end

  def match_status(match) do
    creator_squares = match.match_state[@creator_symbol]
    challenger_squares = match.match_state[@challenger_symbol]

    cond do
      match.challenger === nil ->
        :open

      match.challenger !== nil && length(challenger_squares) === 0 ->
        :accepted

      has_won?(challenger_squares) ->
        :challenger_win

      has_won?(creator_squares) ->
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

  def has_won?(squares) do
    Enum.any?(@winning_combos, &is_winning_combo?(&1, squares))
  end

  def is_draw?(match_state) do
    length(match_state[@creator_symbol]) + length(match_state[@challenger_symbol]) ==
      9
  end

  @doc """
  If a match has been won, this function returns the combo used to win the match.
  Otherwise, `nil` is returned instead.

  This is used by the frontend to draw a line through the winning combo.
  """
  def winning_combo(match) do
    Enum.find(@winning_combos, fn combo ->
      Enum.any?(
        [match.match_state[@creator_symbol], match.match_state[@challenger_symbol]],
        &is_winning_combo?(combo, &1)
      )
    end)
  end

  defp is_winning_combo?(winning_combo, squares) do
    Enum.all?(winning_combo, &(&1 in squares))
  end


  def get_value(match, index) do
    cond do
      index in match.match_state[@creator_symbol] -> @creator_symbol
      index in match.match_state[@challenger_symbol] -> @challenger_symbol
      true -> ""
    end
  end

  def completed_matches(matches) do
    matches
    |> Enum.filter(fn match -> match_status(match) in [:challenger_win, :creator_win, :draw] end)
  end
end
