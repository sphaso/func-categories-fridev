defmodule Tictactoe do
  @moduledoc """
  Documentation for Tictactoe.
  """

  alias Tictactoe.Game

  def print_current_board, do: fn game -> IO.puts(Game.to_string(game)) end

  def parse(input, c) do
    with {:ok, [x, y]} <- {:ok, String.split(input)},
         {:ok, {x, _}} <- {:ok, Integer.parse(x)},
         {:ok, {y, _}} <- {:ok, Integer.parse(y)} do
      {:ok, {x, y, c}}
    else
      _ -> {:error, "validation"}
    end
  end

  # user input? maybe! who knows what they will write
  def ask_user_input do
    fn c ->
      IO.puts("Next move! x y")
      input = IO.read(:stdio, :line)

      cond do
        input == "quit\n" ->
          {:ok, "quit"}

        input == "123" ->
          {:error, "input x y"}

        true ->
          parse(input, c)
      end
    end
  end

  # color is a setoid, but it's so small we can just write this:
  defp inverse_color("b"), do: "w"
  defp inverse_color("w"), do: "b"

  def main(_) do
    play(%{white: [], black: []}, "b")
  end

  def play(game = %{winner: w}, _) do
    print_current_board().(game)
    IO.puts("Congrats #{w}!")
  end

  def play(game, color) do
    print_current_board().(game)

    case ask_user_input().(color) do
      {:ok, "quit"} ->
        System.halt()

      {:error, msg} ->
        IO.puts(msg)
        play(game, color)

      {:ok, move} ->
        {:ok, game} = Game.add_move(game, move)
        play(game, inverse_color(color))
    end
  end
end
