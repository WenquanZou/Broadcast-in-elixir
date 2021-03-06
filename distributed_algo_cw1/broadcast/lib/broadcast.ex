# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Broadcast do
  def main do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["Broadcasting at ", DAC.self_string()]

    # Create peers
    peers = for i <- 0..(no_peers - 1), do:
      DAC.node_spawn("", i, Peer, :start, [])

    #Binding every peer with its neighbours
    for peer <- peers, do:
      send peer, {:bind, peers}

    for peer <- peers, do:
      send peer, { :broadcast, max_broadcasts, timeout }
  end

  # Docker Implementation
  def main_net do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["Broadcasting at ", DAC.self_string()]

    # Create peers
    peers = for i <- 0..(no_peers - 1), do:
      DAC.node_spawn("", i, Peer, :start, [])

    #Binding every peer with its neighbours
    for peer <- peers, do:
      send peer, {:bind, peers}

    for peer <- peers, do:
      send peer, { :broadcast, max_broadcasts, timeout }
  end
end
