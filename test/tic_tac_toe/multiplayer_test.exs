defmodule TicTacToe.MultiplayerTest do
  use TicTacToe.DataCase

  alias TicTacToe.Multiplayer

  describe "matches" do
    alias TicTacToe.Multiplayer.Match

    import TicTacToe.MultiplayerFixtures

    @invalid_attrs %{challenger: nil, creator: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Multiplayer.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Multiplayer.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{challenger: "some challenger", creator: "some creator"}

      assert {:ok, %Match{} = match} = Multiplayer.create_match(valid_attrs)
      assert match.challenger == "some challenger"
      assert match.creator == "some creator"
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multiplayer.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{challenger: "some updated challenger", creator: "some updated creator"}

      assert {:ok, %Match{} = match} = Multiplayer.update_match(match, update_attrs)
      assert match.challenger == "some updated challenger"
      assert match.creator == "some updated creator"
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Multiplayer.update_match(match, @invalid_attrs)
      assert match == Multiplayer.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Multiplayer.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Multiplayer.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Multiplayer.change_match(match)
    end
  end

  describe "players" do
    alias TicTacToe.Multiplayer.Player

    import TicTacToe.MultiplayerFixtures

    @invalid_attrs %{name: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Multiplayer.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Multiplayer.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Player{} = player} = Multiplayer.create_player(valid_attrs)
      assert player.name == "some name"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multiplayer.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Player{} = player} = Multiplayer.update_player(player, update_attrs)
      assert player.name == "some updated name"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Multiplayer.update_player(player, @invalid_attrs)
      assert player == Multiplayer.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Multiplayer.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Multiplayer.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Multiplayer.change_player(player)
    end
  end
end
