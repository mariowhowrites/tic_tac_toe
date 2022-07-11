defmodule TicTacToe.Multiplayer.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phoenix.PubSub


  @pubsub TicTacToe.PubSub

  schema "matches" do
    field :challenger, Ecto.UUID
    field :creator, Ecto.UUID

    field :match_state, :map, default: TicTacToe.Multiplayer.Engine.new_match_state()

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

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:creator, :challenger, :match_state])
    |> validate_required([:creator, :match_state])
  end
end
