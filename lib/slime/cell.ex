# TODO: kill me and replace with a custom type and a tuple {row, col}

defmodule Slime.Cell do
  @type t :: %__MODULE__{row: non_neg_integer(), col: non_neg_integer()}

  defstruct row: 0, col: 0

  @spec new(non_neg_integer(), non_neg_integer()) :: __MODULE__.t()
  def new(row, col), do: %__MODULE__{row: row, col: col}
end
