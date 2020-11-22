defmodule Slime.MoveValidations do
  alias Slime.{Game, Board, Cell}

  @spec validate(Game.t(), Cell.t(), Cell.t()) :: :valid | {:invalid, atom}
  def validate(%Game{} = game, %Cell{} = src, %Cell{} = dest) do
    validators = [
      {&game_is_over/3, :game_is_over},
      {&src_is_out_of_bounds/3, :src_is_out_of_bounds},
      {&dest_is_out_of_bounds/3, :dest_is_out_of_bounds},
      {&src_is_empty/3, :src_is_empty},
      {&src_not_owned_by_current_turn_player/3, :src_not_owned_by_current_turn_player},
      {&dest_is_occupied/3, :dest_is_occupied},
      {&dest_is_too_far_away/3, :dest_is_too_far_away}
    ]

    case Enum.find(validators, fn {func, _} -> apply(func, [game, src, dest]) end) do
      nil -> :valid
      {_, failed_validation} -> {:invalid, failed_validation}
      _ -> {:invalid, :unknown_validation_error}
    end
  end

  defp game_is_over(%Game{} = game, %Cell{} = _src, %Cell{} = _dest), do: Game.is_game_over?(game)

  defp src_is_out_of_bounds(%Game{} = game, %Cell{} = src, %Cell{} = _dest),
    do: Board.player_at(game.board, src) == nil

  defp dest_is_out_of_bounds(%Game{} = game, %Cell{} = _src, %Cell{} = dest),
    do: Board.player_at(game.board, dest) == nil

  defp src_is_empty(%Game{} = game, %Cell{} = src, %Cell{} = _dest),
    do: Board.player_at(game.board, src) == :empty

  defp src_not_owned_by_current_turn_player(%Game{} = game, %Cell{} = src, %Cell{} = _dest) do
    current_turn_player = Game.turn(game)
    current_turn_player != Board.player_at(game.board, src)
  end

  defp dest_is_occupied(%Game{} = game, %Cell{} = _src, %Cell{} = dest),
    do: Board.player_at(game.board, dest) != :empty

  defp dest_is_too_far_away(%Game{} = _game, %Cell{} = src, %Cell{} = dest),
    do: abs(src.row - dest.row) > 2 or abs(src.col - dest.col) > 2
end
