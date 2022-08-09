defmodule TicTacToe.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :creator_id, :int
      add :challenger_id, :int

      add :match_state, :map, null: false

      timestamps()
    end
  end
end
