defmodule BebBroadcastTest do
  use ExUnit.Case
  doctest BebBroadcast

  test "greets the world" do
    assert BebBroadcast.hello() == :world
  end
end
