defmodule TicTacToe.Multiplayer.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phoenix.PubSub
  alias TicTacToe.Accounts.User

  @pubsub TicTacToe.PubSub

  schema "matches" do
    field :match_state, :map, default: TicTacToe.Multiplayer.Engine.new_match_state()

    belongs_to :creator, User
    belongs_to :challenger, User

    timestamps()
  end


  @doc """
  Subscribe
  """
  def subscribe_matches, do: PubSub.subscribe(@pubsub, "matches")

  def broadcast_matches do
    PubSub.broadcast(@pubsub, "matches", :matches)
  end

  @doc """
  Subscribes for updates to a match given its id.
  """
  def subscribe_match(match_id) do
    PubSub.subscribe(@pubsub, "match:#{match_id}")
  end

  def broadcast_match(match_id) do
    PubSub.broadcast(@pubsub, "match:#{match_id}", {:match, match_id})
  end

  defp maybe_add_creator_or_challenger(match, attrs) do
    cond do
      Map.has_key?(attrs, :challenger) -> put_assoc(match, :challenger, attrs.challenger)
      Map.has_key?(attrs, :creator) -> put_assoc(match, :creator, attrs.creator)
      true -> match
    end
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:match_state])
    |> maybe_add_creator_or_challenger(attrs)
    |> validate_required([:match_state, :creator])
  end
end
