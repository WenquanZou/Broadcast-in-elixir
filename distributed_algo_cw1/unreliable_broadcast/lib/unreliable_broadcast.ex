# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule UnreliableBroadcast do
  def main do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["UnreliableBroadcast at ", DAC.self_string()]

    # Create peers
    peers = for (i <- 0..(no_peers - 1)), do:
      DAC.node_spawn("", i, Peer, :start, [self()])

    for peer <- peers, do:
      send(peer, {:bind, peers})

    # Create a map of peer to its own pl using pid
    map_pls = waiting_for_connection(no_peers, %{})

    for peer <- peers, do:
      send peer, {:bindAll, map_pls}

    for pl <- Map.values(map_pls), do:
      send pl, {:pl_deliver, self(), {:beb_broadcast, max_broadcasts, timeout }}
  end

  def waiting_for_connection(no_pls, pls_map) do
    # If all the PLs are received
    if (map_size(pls_map) == no_pls) do
      pls_map
    else
      receive do
        {:pl_created, pid_peer, pid_pl} ->
          # If not, wait for the signal and add in the current pid_pl & peer pid to the map
          waiting_for_connection(no_pls, Map.put(pls_map, pid_peer, pid_pl))
        # Time limit for the wait
        after 3000 ->
          IO.puts "Cannot retrieve all the pl created"
      end
    end
  end

  # Docker Implementation
  def main_net do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["UnreliableBroadcast at ", DAC.self_string()]

    # Create peers
    peers = for (i <- 0..(no_peers - 1)), do:
      DAC.node_spawn("", i, Peer, :start, [self()])

    for peer <- peers, do:
      send(peer, {:bind, peers})

    map_pls = waiting_for_connection(no_peers, %{})
    for peer <- peers, do:
      send peer, {:bindAll, map_pls}

    for pl <- Map.values(map_pls), do:
      send pl, {:pl_deliver, self(), {:beb_broadcast, max_broadcasts, timeout }}
  end
end
