defmodule Slime.MoveValidations do
  alias Slime.{Game, Board}

  @type cell :: Slime.Game.cell()

  @spec validate(Game.t(), cell, cell) :: :valid | {:invalid, atom}
  def validate(%Game{} = game, src, dest) do
    validators = [
      {&game_is_over/3, :game_is_over},
      {&src_is_out_of_bounds/3, :src_is_out_of_bounds},
      {&dest_is_out_of_bounds/3, :dest_is_out_of_bounds},
      {&src_is_empty/3, :src_is_empty},
      {&src_not_owned_by_current_turn_player/3, :src_not_owned_by_current_turn_player},
      {&dest_is_occupied/3, :dest_is_occupied},
      {&dest_is_too_far_away/3, :dest_is_too_far_away}
    ]

    validate(validators, [game, src, dest])
  end

  @spec validate_select(Game.t(), cell) :: :valid | {:invalid, atom}
  def validate_select(%Game{} = game, src) do
    validators = [
      {&game_is_over/3, :game_is_over},
      {&src_is_out_of_bounds/3, :src_is_out_of_bounds},
      {&src_is_empty/3, :src_is_empty},
      {&src_not_owned_by_current_turn_player/3, :src_not_owned_by_current_turn_player}
    ]

    validate(validators, [game, src, nil])
  end

  defp validate(validators, args) do
    case Enum.find(validators, fn {func, _} -> apply(func, args) end) do
      nil -> :valid
      {_, failed_validation} -> {:invalid, failed_validation}
      _ -> {:invalid, :unknown_validation_error}
    end
  end

  defp game_is_over(%Game{} = game, _src, _dest), do: Game.is_game_over?(game)

  defp src_is_out_of_bounds(%Game{} = game, src, _dest),
    do: Board.player_at(game.board, src) == nil

  defp dest_is_out_of_bounds(%Game{} = game, _src, dest),
    do: Board.player_at(game.board, dest) == nil

  defp src_is_empty(%Game{} = game, src, _dest),
    do: Board.player_at(game.board, src) == :empty

  defp src_not_owned_by_current_turn_player(%Game{} = game, src, _dest) do
    current_turn_player = Game.turn(game)
    current_turn_player != Board.player_at(game.board, src)
  end

  defp dest_is_occupied(%Game{} = game, _src, dest),
    do: Board.player_at(game.board, dest) != :empty

  defp dest_is_too_far_away(%Game{} = _game, src, dest),
    do: abs(row(src) - row(dest)) > 2 or abs(col(src) - col(dest)) > 2

  defp row({r, _c}), do: r
  defp col({_r, c}), do: c
end
