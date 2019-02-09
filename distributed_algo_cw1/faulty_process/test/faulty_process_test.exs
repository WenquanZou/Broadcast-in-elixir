defmodule FaultyProcessTest do
  use ExUnit.Case
  doctest FaultyProcess

  test "greets the world" do
    assert FaultyProcess.hello() == :world
  end
end
