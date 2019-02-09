defmodule UnreliableBroadcastTest do
  use ExUnit.Case
  doctest UnreliableBroadcast

  test "greets the world" do
    assert UnreliableBroadcast.hello() == :world
  end
end
