defmodule TicTacToe.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :creator, :uuid, null: false
      add :challenger, :uuid

      add :match_state, :map, null: false

      timestamps()
    end
  end
end
