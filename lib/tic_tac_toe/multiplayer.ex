defmodule TicTacToe.Multiplayer do
  @moduledoc """
  The Multiplayer context.
  """

  import Ecto.Query, warn: false
  alias TicTacToe.Repo
  alias TicTacToe.Multiplayer.{Match,Engine}

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match |> order_by(desc: :inserted_at) |> preload([:creator, :challenger]))
  end

  # List all matches that are not yet completed. IE: where the match status is not `draw`, `creator_win`, or `challenger_win`.
  def list_non_completed_matches do
    matches = list_matches()

    Enum.filter(matches, fn match ->
      Engine.match_status(match) not in [:challenger_win, :creator_win, :draw]
    end)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id) |> Repo.preload([:creator, :challenger])

  def is_match_creator?(match, user) do
    match.creator === user
  end

  def is_match_challenger?(match, user) do
    match.challenger === user
  end

  def is_match_open?(match) do
    match.challenger === nil
  end

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    match =
      %Match{}
      |> Match.changeset(attrs)
      |> Repo.insert()

    Match.broadcast_matches()

    match
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  def update_match_state(%Match{} = match, role, index) do
    IO.inspect {match, role, index}

    new_match =
      case update_match(
             match,
             %{match_state: Engine.update_match_state(match, role, index)}
           ) do
        {:ok, new_match} -> new_match
        {:error, _} -> match
      end


    Match.broadcast_match(new_match.id)

    new_match
  end

  def get_status_text(%Match{} = match) do
    case Engine.match_status(match) do
      :open -> "Open"
      :accepted -> "Accepted"
      :challenger_win -> "Challenger Wins"
      :creator_win -> "Creator Wins"
      :challenger_turn -> "Challenger Turn"
      :creator_turn -> "Creator Turn"
      :draw -> "Tie"
    end
  end

  def add_match_challenger(%Match{} = match, user) do
    {:ok, match} = Repo.get(Match, match.id)
    |> Repo.preload([:creator, :challenger])
    |> Match.changeset(%{challenger: user})
    |> Repo.update()

    Match.broadcast_matches()
    Match.broadcast_match(match.id)

    {:ok, match}
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  def display_name(:creator, match, user) do
    case is_match_creator?(match, user) do
      true -> "You"
      false -> match.creator.email
    end
  end

  def display_name(:challenger, match, user) do
    case match.challenger do
      nil -> "Nobody... yet"
      ^user -> "You"
      _default -> match.challenger.email
    end
  end

  def user_win_rate(user) do
    total_wins = length(challenger_wins(user)) + length(creator_wins(user))

    total_wins / length(Engine.completed_matches(user.challenger_matches ++ user.creator_matches)) * 100
  end

  def challenger_wins(user) do
    user.challenger_matches
    |> Enum.filter(fn match -> Engine.match_status(match) === :challenger_win end)
  end

  def creator_wins(user) do
    user.creator_matches
    |> Enum.filter(fn match -> Engine.match_status(match) === :creator_win end)
  end
end
