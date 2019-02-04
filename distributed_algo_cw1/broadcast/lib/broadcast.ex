defmodule Broadcast do
  def main do
    no_peers = 0..(5 - 1)
    max_broadcasts = 1000
    timeout = 3000
    # Create peers
    peers = for i <- no_peers, do:
      DAC.node_spawn("", 1, Peer, :start, [])

    #Binding every peer with its neighbours
    for peer <- peers, do:
      send peer, {:bind, peers}
    for peer <- peers, do:
      send peer, { :broadcast, max_broadcasts, timeout }
  end
end
