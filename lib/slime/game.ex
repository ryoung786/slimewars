defmodule Slime.Game do
  alias __MODULE__, as: Game
  alias Slime.{Board, Cell}

  @type t :: %Game{board: Board.t(), players: [], current_player_index: non_neg_integer()}

  defstruct board: %Board{},
            players: [:blue, :green],
            current_player_index: 0

  @default_width 7
  @default_height 7

  def new(width \\ @default_width, height \\ @default_height),
    do: %Game{board: Board.new(width, height)}

  @spec is_game_over?(Game.t()) :: boolean
  def is_game_over?(%Game{board: board}) do
    Board.count_empty_cells(board) == 0
  end

  def game_in_progress?(%Game{} = game), do: !is_game_over?(game)

  @spec winner(Game.t()) :: {:ok, atom()} | {:error, String.t()}
  def winner(%Slime.Game{board: board} = game) do
    if is_game_over?(game) do
      {player, _score} = Board.cell_frequencies(board) |> Enum.max_by(fn {_k, v} -> v end)
      {:ok, player}
    else
      {:error, "Game still in progress"}
    end
  end

  @spec winner!(Game.t()) :: atom()
  def winner!(%Game{} = game) do
    with {:ok, player} <- winner(game) do
      player
    else
      {:error, msg} -> raise(msg)
    end
  end

  @spec turn(Game.t()) :: atom
  def turn(%Game{} = game) do
    game.players |> Enum.at(game.current_player_index)
  end

  @spec move(Game.t(), Cell.t(), Cell.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def move(%Game{} = game, %Cell{} = src, %Cell{} = dest) do
    with :valid <- validate_move(game, src, dest) do
      {:ok, update_board(game, src, dest)}
    else
      {:invalid, reason} -> {:invalid_move, reason}
    end
  end

  @spec update_board(Game.t(), Cell.t(), Cell.t()) :: Game.t()
  defp update_board(%Game{} = game, %Cell{} = src, %Cell{} = dest) do
    %Game{
      board: Board.move(game.board, src, dest),
      players: game.players,
      current_player_index: rem(game.current_player_index + 1, length(game.players))
    }
  end

  defp validate_move(%Game{} = game, %Cell{} = src, %Cell{} = dest),
    do: Slime.MoveValidations.validate(game, src, dest)
end
