defmodule PlBroadcastTest do
  use ExUnit.Case
  doctest PlBroadcast

  test "greets the world" do
    assert PlBroadcast.hello() == :world
  end
end
