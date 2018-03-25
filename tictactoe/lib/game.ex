defmodule Tictactoe.Game do
  @moduledoc """
  Game functionalities
  """

  import Tictactoe.Point

  # game logic
  # when we add a move, many things could happend, including errors!
  # that's why we wrap our game structure into a Maybe
  def add_move(game, move = {x, y, _}) do
    if !free?(game, {x, y}) do
      {:error, "A stone is already present"}
    else
      {:ok, add_to_square(game, move)}
    end
  end

  @doc """
  iex> #{__MODULE__}.to_string(%{white: [[{2,1}, {2,2}, {2,3}]], black: [[{1,1}, {1,2}, {1,3}]]})
  "BBB\nWWW\n   "
  """
  def to_string(%{white: w, black: b}) do
    empty_board()
    |> Enum.map(fn s ->
      cond do
        has_stone(Enum.concat(w), s) -> "W"
        has_stone(Enum.concat(b), s) -> "B"
        true -> " "
      end
    end)
    |> Enum.chunk_every(3)
    |> Enum.intersperse(["\n"])
    |> Enum.concat()
    |> Enum.join()
  end

  @doc """
  iex> #{__MODULE__}.empty_board()
  [{1,1}, {1,2}, {1,3}, {2,1}, {2,2}, {2,3}, {3,1}, {3,2}, {3,3}]
  """
  def empty_board do
    for x <- 1..3 do
      for y <- 1..3 do
        {x, y}
      end
    end
    |> Enum.concat()
  end

  def add_to_square(g, m) do
    game = %{white: w, black: b} = do_add_to_square(g, m)

    cond do
      has_won(w) -> Map.put(game, :winner, "w")
      has_won(b) -> Map.put(game, :winner, "b")
      true -> game
    end
  end

  def do_add_to_square(g = %{white: w}, {x, y, "w"}) do
    %{g | white: mconcat(w, {x, y})}
  end

  def do_add_to_square(g = %{black: b}, {x, y, "b"}) do
    %{g | black: mconcat(b, {x, y})}
  end

  # monoidal
  @doc """
  iex> #{__MODULE__}.mconcat([], {1, 1})
  [[{1, 1}]]

  iex> #{__MODULE__}.mconcat([[{1, 1}]], {1, 2})
  [[{1, 2}], [{1, 1}, {1, 2}]]

  iex> #{__MODULE__}.mconcat([[{1, 1}, {2, 2}]], {1, 2})
  [[{2, 2}, {1, 2}], [{1, 1}, {1, 2}], [{1, 2}]]
  """
  def mconcat(strings, move) do
    [&horizontal?/2, &vertical?/2, &diagonal?/2, &contradiagonal?/2]
    |> Enum.map(&append_if(strings, move, &1))
    |> Enum.uniq()
  end

  defp append_if(strings, move, strategy) do
    strings
    |> Enum.map(&Enum.filter(&1, fn m -> strategy.(m, move) end))
    |> Enum.concat()
    |> Kernel.++([move])
    |> Enum.uniq()
  end

  # predicates

  def has_stone(group, m) do
    Enum.any?(group, &eq(&1, m))
  end

  def free?(%{black: b, white: w}, m) do
    b
    |> Kernel.++(w)
    |> Enum.concat()
    |> Enum.uniq()
    |> has_stone(m)
    |> Kernel.not()
  end

  @doc """
  iex> #{__MODULE__}.has_won([[1, 2, 3], [1, 3], []])
  true

  iex> #{__MODULE__}.has_won([[1, 3], [1], []])
  false
  """
  def has_won(strings), do: Enum.any?(strings, &(length(&1) == 3))
end
