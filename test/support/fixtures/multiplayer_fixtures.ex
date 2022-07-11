defmodule TicTacToe.MultiplayerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TicTacToe.Multiplayer` context.
  """

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{
        challenger: "some challenger",
        creator: "some creator"
      })
      |> TicTacToe.Multiplayer.create_match()

    match
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> TicTacToe.Multiplayer.create_player()

    player
  end
end
