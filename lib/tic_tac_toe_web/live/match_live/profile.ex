defmodule TicTacToeWeb.MatchLive.Profile do
  use TicTacToeWeb, :live_view
  alias TicTacToe.Accounts
  alias TicTacToe.Multiplayer

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)

    {
      :ok,
      socket
      |> assign(:user, user)
    }
  end
end
