defmodule EagerReliableBroadcastTest do
  use ExUnit.Case
  doctest EagerReliableBroadcast

  test "greets the world" do
    assert EagerReliableBroadcast.hello() == :world
  end
end
