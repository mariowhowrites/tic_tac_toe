defmodule TicTacToeWeb.MatchLive.FormComponent do
  use TicTacToeWeb, :live_component

  alias TicTacToe.Multiplayer

  @impl true
  def update(%{match: match} = assigns, socket) do
    changeset = Multiplayer.change_match(match)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"match" => match_params}, socket) do
    changeset =
      socket.assigns.match
      |> Multiplayer.change_match(match_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"match" => match_params}, socket) do
    save_match(socket, socket.assigns.action, match_params)
  end

  defp save_match(socket, :new, match_params) do
    case Multiplayer.create_match(match_params) do
      {:ok, _match} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
