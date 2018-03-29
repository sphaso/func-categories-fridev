defmodule JointsTest do
    use ExUnit.Case
    doctest Parser.Joints

    alias Parser.Joints

    test "many" do
        assert {:ok, [1, 1, 1, 1, 1, 1, 1, 1], ""} == Joints.many(&Joints.number/1).("11111111")        
    end

    test "discard" do
        assert {:ok, nil, "a "} == Joints.discard(&Joints.space/1).(" a ")
    end

    test "por" do
        new_parser = Joints.por(&Joints.number/1, &Joints.space/1)

        assert {:ok, [1, :space], ""} == new_parser.("1 ")
        assert {:ok, 1, "x"} == new_parser.("1x")
        assert {:ok, :space, "1"} == new_parser.(" 1")
    end

    test "pand" do
        new_parser = Joints.pand(&Joints.number/1, &Joints.space/1)

        assert {:ok, [1, :space], ""} == new_parser.("1 ")
        assert {:error, "x "} == new_parser.("x ")
        assert {:error, "1x"} == new_parser.("1x")
    end

    test "any" do
        new_parser = Joints.any([&Joints.number/1, &Joints.paren/1, &Joints.operand/1])

        assert {:ok, 1, "()"} == new_parser.("1()")
        assert {:ok, :open_par, "()"} == new_parser.("(()")
        assert {:ok, :plus, "()"} == new_parser.("+()")
    end

    test "let the math begin" do
        no_spaces = Joints.discard(Joints.many(&Joints.space/1))
        any_char = Joints.many(Joints.any([&Joints.number/1, &Joints.paren/1, &Joints.operand/1]))

        new_parser = Joints.many(Joints.por(no_spaces, any_char))

        assert {:ok, [1, :plus, 1], ""} == new_parser.("1+1")
        assert {:ok, [1, :plus, 1], ""} == new_parser.("1 + 1")
    end
end