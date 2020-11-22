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

    if Game.can_select(socket.assigns.game, {r, c}) do
      {:noreply, assign(socket, selected: {r, c})}
    else
      {:noreply, socket |> put_flash(:error, "You can't select that cell")}
    end
  end

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

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not SlimeWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
