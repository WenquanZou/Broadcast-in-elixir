defmodule BEBBroadcast do
  def main do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["BebBroadcasting at ", DAC.self_string()]

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

  def waiting_for_connection(no_pls, pls_map) do
    if (map_size(pls_map) == no_pls) do
      pls_map
    else
      receive do
        {:pl_created, pid_peer, pid_pl} ->
          waiting_for_connection(no_pls, Map.put(pls_map, pid_peer, pid_pl))
      end
    end
  end

  def main_net do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["BebBroadcasting at ", DAC.self_string()]

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
