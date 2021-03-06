defmodule Slime.MoveValidationsTest do
  use ExUnit.Case, async: true
  alias Slime.{Game, Board}
  alias Slime.MoveValidations, as: MV

  setup_all do
    sample_games()
  end

  test "game is over", games do
    assert {:invalid, :game_is_over} == MV.validate(games.blue_win, {0, 0}, {1, 1})
    assert {:invalid, :game_is_over} == MV.validate(games.green_win, {0, 0}, {1, 1})
  end

  test "src is out of bounds", %{new_game: game} do
    assert {:invalid, :src_is_out_of_bounds} == MV.validate(game, {-1, 0}, {1, 1})
    assert {:invalid, :src_is_out_of_bounds} == MV.validate(game, {10, 0}, {1, 1})
    assert {:invalid, :src_is_out_of_bounds} == MV.validate(game, {1, 7}, {1, 1})
    assert {:invalid, :src_is_out_of_bounds} == MV.validate(game, {1, 7}, {1, -34})
  end

  test "dest is out of bounds", %{new_game: game} do
    assert {:invalid, :dest_is_out_of_bounds} == MV.validate(game, {1, 1}, {-1, 0})
    assert {:invalid, :dest_is_out_of_bounds} == MV.validate(game, {1, 1}, {10, 0})
    assert {:invalid, :dest_is_out_of_bounds} == MV.validate(game, {1, 1}, {1, 7})
  end

  test "src is empty", %{new_game: game} do
    assert {:invalid, :src_is_empty} == MV.validate(game, {1, 1}, {1, 2})
  end

  test "src is not owned by current player", %{new_game: game} do
    assert {:invalid, :src_not_owned_by_current_turn_player} ==
             MV.validate(game, {6, 0}, {4, 2})
  end

  test "dest is occupied", %{new_game: game} do
    assert {:invalid, :dest_is_occupied} == MV.validate(game, {0, 0}, {6, 0})
  end

  test "dest is too far away", %{new_game: game} do
    assert {:invalid, :dest_is_too_far_away} == MV.validate(game, {0, 0}, {3, 0})
    assert {:invalid, :dest_is_too_far_away} == MV.validate(game, {6, 6}, {5, 1})
  end

  test "valid move", %{new_game: game} do
    assert :valid == MV.validate(game, {0, 0}, {1, 0})
    assert :valid == MV.validate(game, {0, 0}, {0, 1})
    assert :valid == MV.validate(game, {0, 0}, {1, 1})
    assert :valid == MV.validate(game, {6, 6}, {4, 4})
    assert :valid == MV.validate(game, {6, 6}, {4, 5})
  end

  defp sample_games() do
    %{
      new_game: Game.new(),
      blue_win: %Game{
        board: %Board{
          cells:
            Slime.Matrix.from_list([
              [:blue, :blue, :blue, :blue, :blue, :blue, :green],
              [:blue, :blue, :blue, :blue, :blue, :blue, :blue],
              [:blue, :blue, :blue, :green, :blue, :blue, :blue],
              [:blue, :blue, :blue, :blue, :blue, :blue, :blue],
              [:blue, :blue, :green, :blue, :blue, :blue, :blue],
              [:blue, :blue, :blue, :blue, :blue, :blue, :blue],
              [:green, :blue, :blue, :blue, :blue, :blue, :blue]
            ])
        }
      },
      green_win: %Game{
        board: %Board{
          cells:
            Slime.Matrix.from_list([
              [:green, :green, :green, :green, :green, :green, :blue],
              [:green, :green, :green, :green, :green, :green, :green],
              [:green, :green, :green, :blue, :green, :green, :green],
              [:green, :green, :green, :green, :green, :green, :green],
              [:green, :green, :blue, :green, :green, :green, :green],
              [:green, :green, :green, :green, :green, :green, :green],
              [:blue, :green, :green, :green, :green, :green, :green]
            ])
        }
      },
      no_blue_left: %Game{
        board: %Board{
          cells:
            Slime.Matrix.from_list([
              [:green, :green, :green, :green, :green, :green, :empty],
              [:green, :green, :green, :green, :green, :green, :green],
              [:green, :green, :green, :empty, :green, :green, :green],
              [:green, :green, :green, :green, :green, :green, :green],
              [:green, :green, :empty, :green, :green, :green, :green],
              [:green, :green, :green, :green, :green, :green, :green],
              [:empty, :green, :green, :green, :green, :green, :green]
            ])
        }
      }
    }
  end
end
