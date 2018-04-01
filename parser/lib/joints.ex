defmodule Parser.Joints do
    @moduledoc """
    Utility functions for our powerful parser!
    """

    # all the basic functions in this module have the same signature
    # string -> Maybe (a, string)
    # so we can combine them :)
    
    @doc """
    iex> #{__MODULE__}.number("12")
    {:ok, 1, "2"}

    iex> #{__MODULE__}.number("a2")
    {:error, "a2"}
    """
    def number(s = << head::bytes-size(1) >> <> tail) do
        case Integer.parse(head) do
            {num, ""} -> {:ok, num, tail}
            :error    -> {:error, s}
        end
    end
    def number(s), do: {:error, s}

    @doc """
    iex> #{__MODULE__}.paren("(2")
    {:ok, :open_par, "2"}

    iex> #{__MODULE__}.paren(")2")
    {:ok, :closed_par, "2"}

    iex> #{__MODULE__}.paren("a2")
    {:error, "a2"}
    """
    def paren("(" <> tail), do: {:ok, :open_par, tail}
    def paren(")" <> tail), do: {:ok, :closed_par, tail}
    def paren(string), do: {:error, string}
        
    def operand("+" <> tail), do: {:ok, :plus, tail}
    def operand("*" <> tail), do: {:ok, :mult, tail}
    def operand("-" <> tail), do: {:ok, :sub, tail}
    def operand("/" <> tail), do: {:ok, :div, tail}
    def operand(s), do: {:error, s}

    def space(" " <> tail), do: {:ok, :space, tail}
    def space(string), do: {:error, string}

    # combinators
    # (string -> Maybe (a, string)) -> string -> Maybe (a, string)
    # guess what... this is monadic composition! (bind)

    # results are treated as semigroups / monoids
    def mappend({:ok, a, _}, {:ok, b, tail}), do: {:ok, mappend(a, b), tail}
    def mappend({:ok, a, _}, {:error, t}), do: {:error, to_string(a) <> t}
    def mappend(a = {:error, _}, _), do: a
    def mappend(nil, nil), do: []
    def mappend(nil, a), do: [a]
    def mappend(a, nil), do: [a]
    def mappend(a, b), do: [a, b]

    # a functor never hurts
    def fmap(_parser, {:error, tail}), do: {:error, tail}
    def fmap(parser, r = {:ok, _, tail}), do: mappend(r, parser.(tail))

    def many(parser) do
        fn str ->
            case manyp(parser, str, []) do
                {[], tail}  -> {:error, tail}
                {acc, tail} -> {:ok, List.flatten(acc), tail}
            end
        end
    end
    defp manyp(parser, str, acc) do
        case parser.(str) do
            {:ok, s, tail} -> manyp(parser, tail, mappend(s, acc))
            {:error, tail} -> {acc, tail}
        end
    end

    def discard(parser) do
        fn str ->
            case parser.(str) do
                {:ok, _s, tail} -> {:ok, nil, tail}
                {:error, str}  -> {:error, str}
            end
        end
    end

    def por(parse1, parse2) do
        fn s ->
            case parse1.(s) do
                r = {:ok, a, tail} -> case parse2.(tail) do
                                        {:ok, b, t} -> {:ok, mappend(a, b), t}
                                        {:error, _} -> r
                                       end
                {:error, t} -> parse2.(t)
             end
        end
    end

    def pand(parse1, parse2) do
        fn s -> fmap(parse2, parse1.(s)) end
    end

    def any(parsers) do
        fn s -> 
            parsers
            |> Enum.find(fn parser ->
                elem(parser.(s), 0) == :ok
            end)
            |> case do
               nil    -> {:error, s}
               parser -> parser.(s)
            end
        end
    end
end