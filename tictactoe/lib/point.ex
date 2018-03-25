defmodule Tictactoe.Point do
  @moduledoc """
  We think of points in terms of setoids:
   all we care about is if they're equal
  """

  # predicates
  def eq({x0, y0}, {x, y}), do: x0 == x && y0 == y

  def horizontal?({_, y0}, {_, y}), do: y0 == y

  def vertical?({x0, _}, {x, _}), do: x0 == x

  def diagonal?(m, n) do
    eq(northeast(m), n) || eq(northeast(northeast(m)), n) || eq(southwest(m), n) ||
      eq(southwest(southwest(m)), n)
  end

  def contradiagonal?(m, n) do
    eq(northwest(m), n) || eq(northwest(northwest(m)), n) || eq(southeast(m), n) ||
      eq(southeast(southeast(m)), n)
  end

  # utilities

  def north({x, y}), do: {x, y + 1}

  def south({x, y}), do: {x, y - 1}

  def east({x, y}), do: {x + 1, y}

  def west({x, y}), do: {x - 1, y}

  def northwest(p), do: north(west(p))

  def northeast(p), do: north(east(p))

  def southeast(p), do: south(east(p))

  def southwest(p), do: south(west(p))
end
