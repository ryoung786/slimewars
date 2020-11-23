defmodule SlimeWeb.GameLive do
  use SlimeWeb, :live_view
  alias Slime.{Game, Matrix}

  @impl true
  def mount(_params, _session, socket) do
    game = Game.new()
    {:ok, assign(socket, game: game, selected: nil)}
  end

  @impl true
  def handle_event("select", %{"row" => r, "col" => c}, socket) do
    [r, c] = Enum.map([r, c], &String.to_integer/1)

    case Game.can_select(socket.assigns.game, {r, c}) do
      true -> {:noreply, assign(socket, selected: {r, c})}
      _ -> {:noreply, socket |> put_flash(:error, "You can't select that cell")}
    end
  end

  @impl true
  def handle_event("deselect", _data, socket), do: {:noreply, assign(socket, selected: nil)}

  @impl true
  def handle_event("move", %{"row" => r, "col" => c}, socket) do
    [r, c] = Enum.map([r, c], &String.to_integer/1)
    src = socket.assigns.selected
    dest = {r, c}

    with {:ok, game} <- Game.move(socket.assigns.game, src, dest) do
      {:noreply, assign(socket, game: game, selected: nil)}
    else
      {:invalid_move, reason} -> {:noreply, socket |> put_flash(:error, reason)}
    end
  end
end
