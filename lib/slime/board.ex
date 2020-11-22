defmodule Slime.Board do
  alias __MODULE__, as: Board
  alias Slime.Cell

  @typedoc """
  Represents the game grid
  """
  @type t :: %Board{width: integer, height: integer, cells: Slime.Matrix.t()}

  @default_width 7
  @default_height 7

  defstruct width: @default_width,
            height: @default_height,
            cells: Slime.Matrix.from_list([[:empty]])

  def new(width, height) do
    %Board{width: width, height: height, cells: starting_cells(width, height, :blue, :green)}
  end

  @spec cell_frequencies(Board.t()) :: map()
  def cell_frequencies(%Board{cells: cells}) do
    cells
    |> Map.values()
    |> Enum.map(&Map.values/1)
    |> List.flatten()
    |> Enum.frequencies()
  end

  @spec count_empty_cells(Board.t()) :: integer()
  def count_empty_cells(%Board{} = board) do
    freq = cell_frequencies(board)
    Map.get(freq, :empty, 0)
  end

  @spec player_at(Board.t(), Cell.t()) :: atom()
  def player_at(%Board{cells: cells}, %Cell{row: r, col: c}), do: cells[r][c]

  @spec place_cell(Board.t(), Cell.t(), atom()) :: Board.t()
  def place_cell(%Board{cells: cells} = board, %Cell{row: r, col: c} = _dest, player) do
    cells = put_in(cells[r][c], player)
    # todo: flip surrounding cells
    %{board | cells: cells}
  end

  defp starting_cells(width, height, p1, p2) do
    empty_board(width, height)
    |> put_in([0, 0], p1)
    |> put_in([0, width - 1], p2)
    |> put_in([height - 1, 0], p2)
    |> put_in([height - 1, width - 1], p1)
  end

  @spec empty_board(non_neg_integer(), non_neg_integer()) :: Slime.Matrix.t()
  def empty_board(width, height) do
    lst =
      for _ <- 1..height do
        for _ <- 1..width do
          :empty
        end
      end

    Slime.Matrix.from_list(lst)
  end

  @spec move(Board.t(), Cell.t(), Cell.t()) :: Board.t()
  def move(%Board{} = board, %Cell{} = src, %Cell{} = dest) do
    board =
      case abs(src.row - dest.row) < 2 and abs(src.col - dest.col) < 2 do
        true -> duplicate_cell(board, src, dest)
        false -> jump_cell(board, src, dest)
      end

    flip_neighbors(board, dest)
  end

  @spec duplicate_cell(Board.t(), Cell.t(), Cell.t()) :: Board.t()
  defp duplicate_cell(%Board{} = board, %Cell{} = src, %Cell{} = dest) do
    put_in(board.cells[dest.row][dest.col], board.cells[src.row][src.col])
  end

  @spec jump_cell(Board.t(), Cell.t(), Cell.t()) :: Board.t()
  defp jump_cell(%Board{} = board, %Cell{} = src, %Cell{} = dest),
    do: board |> duplicate_cell(src, dest) |> remove_from_cell(src)

  @spec remove_from_cell(Board.t(), Cell.t()) :: Board.t()
  defp remove_from_cell(%Board{} = board, %Cell{row: r, col: c} = _cell),
    do: put_in(board.cells[r][c], :empty)

  @spec flip_neighbors(Board.t(), Cell.t()) :: Board.t()
  defp flip_neighbors(%Board{} = board, %Cell{row: r, col: c} = _cell) do
    player = board.cells[r][c]
    neighbor_vectors = for i <- [-1, 0, 1], j <- [-1, 0, 1], do: {i, j}

    neighbor_vectors
    |> Enum.reject(fn {y, x} -> y == 0 and x == 0 end)
    |> Enum.map(fn {y, x} -> Cell.new(r + y, c + x) end)
    |> Enum.reduce(board, fn cell, acc -> flip_cell(acc, cell, player) end)
  end

  @spec flip_cell(Board.t(), Cell.t(), atom) :: Board.t()
  defp flip_cell(%Board{} = board, %Cell{row: r, col: c} = cell, player) do
    case board.cells[r][c] do
      nil -> board
      :empty -> board
      _ -> place_cell(board, cell, player)
    end
  end
end

defimpl Inspect, for: Slime.Board do
  def inspect(board, _opts) do
    """
    #{board.width}x#{board.height}
    #{Kernel.inspect(Slime.Matrix.to_list(board.cells), pretty: true, width: 100)}
    """
    |> String.replace(":blue", "B")
    |> String.replace(":green", "G")
    |> String.replace(":empty", " ")
  end
end
