defmodule Slime.GameTest do
  use ExUnit.Case, async: true
  alias Slime.{Game, Board}

  setup_all do
    sample_games()
  end

  test "dimensions are correct", %{new_game: new_game} do
    assert %Game{board: %Board{width: 7, height: 7}} = new_game
    assert %Game{board: %Board{width: 3, height: 3}} = Game.new(3, 3)
  end

  describe "win conditions" do
    test "no winner of brand new game", %{new_game: new_game} do
      assert Game.game_in_progress?(new_game)
      assert Game.is_game_over?(new_game) == false

      assert Game.winner(new_game) == {:error, "Game still in progress"}
    end

    test "winner! raises an exception if game is still in progress", %{new_game: new_game} do
      assert_raise RuntimeError, fn -> Game.winner!(new_game) end
    end

    test "picks correct winner", ctx do
      assert Game.winner!(ctx.blue_win) == :blue
      assert Game.winner!(ctx.green_win) == :green
    end
  end

  describe "moves:" do
    test "can duplicate", %{new_game: game} do
      {:ok, game} = Game.move(game, {0, 0}, {1, 1})
      assert Board.player_at(game.board, {0, 0}) == :blue
      assert Board.player_at(game.board, {1, 1}) == :blue
    end

    test "can jump", %{new_game: game} do
      {:ok, game} = Game.move(game, {0, 0}, {2, 2})
      assert Board.player_at(game.board, {0, 0}) == :empty
      assert Board.player_at(game.board, {2, 2}) == :blue
    end

    test "can flip neighbors", %{to_flip: game} do
      # blue @[3,1] and green @[4,2],[2,3] and empty everywhere else
      # cloning blue to @3,2 should flip both green, and no green left on board
      {:ok, game} = Game.move(game, {3, 1}, {3, 2})
      assert Board.player_at(game.board, {3, 1}) == :blue
      assert Board.player_at(game.board, {3, 2}) == :blue
      assert Board.player_at(game.board, {4, 2}) == :blue
      assert Board.player_at(game.board, {2, 3}) == :blue
    end

    # Before:      After:
    # [B, , ,G]    [ , , ,B]
    # [ , , , ]    [ , ,B, ]
    # [ , , , ]    [ , , , ]
    # [G, , ,B]    [G, , ,B]
    test "before after" do
      {:ok, game} = Game.move(Game.new(4, 4), {0, 0}, {1, 2})

      expected =
        g("""
                  [ , , ,B]
                  [ , ,B, ]
                  [ , , , ]
                  [G, , ,B]
        """)

      assert game.board.cells == expected.board.cells
    end
  end

  test "empty board still reports scores for all players", ctx do
    assert %{blue: 2, green: 0} = Game.score(ctx.no_green)
    assert %{blue: 2, green: 2} = Game.score(ctx.new_game)
    assert %{blue: 4, green: 45} = Game.score(ctx.green_win)
    assert %{blue: 45, green: 4} = Game.score(ctx.blue_win)
  end

  defp g(arr) do
    game = Game.new(4, 4)

    arr =
      String.split(arr, "\n", trim: true)
      |> Enum.map(fn row ->
        String.trim(row)
        |> String.replace("[", "")
        |> String.replace("]", "")
        |> String.split(",", trim: true)
        |> Enum.map(fn cell ->
          case cell do
            " " -> :empty
            "B" -> :blue
            "G" -> :green
          end
        end)
      end)

    put_in(game.board.cells, Slime.Matrix.from_list(arr))
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
      to_flip: %Game{
        board: %Board{
          cells:
            Slime.Matrix.from_list([
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :green, :empty, :empty, :empty],
              [:empty, :blue, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :green, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty]
            ])
        }
      },
      no_green: %Game{
        board: %Board{
          cells:
            Slime.Matrix.from_list([
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :blue, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :blue, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty],
              [:empty, :empty, :empty, :empty, :empty, :empty, :empty]
            ])
        }
      }
    }
  end
end
