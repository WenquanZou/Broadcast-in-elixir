defmodule PLBroadcast do
  def main do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["PLBroadcasting at ", DAC.self_string()]

    # Create peers
    for i <- 0..(no_peers - 1), do:
      DAC.node_spawn("", 1, Peer, :start, [self()])

    all_pls = waiting_for_connection(no_peers, [])
    for pl <- all_pls, do:
      send pl, {:bind, all_pls}

    for pl <- all_pls, do:
      send pl, { :pl_deliver, {:broadcast, max_broadcasts, timeout }, self()}
  end

  def waiting_for_connection(no_pls, pls) do
    if (length(pls) == no_pls) do
      pls
    else
      receive do
        {:pl_created, pid_pl} ->
          waiting_for_connection(no_pls, pls ++ [pid_pl])
      end
    end
  end

  def main_net do
    no_peers = hd(DAC.int_args())
    max_broadcasts = 1000
    timeout = 3000

    IO.puts ["PLBroadcasting at ", DAC.self_string()]

    # Create peers
    for i <- 0..(no_peers - 1), do:
      DAC.node_spawn("", i, Peer, :start, [self()])

    all_pls = waiting_for_connection(no_peers, [])
    for pl <- all_pls, do:
      send pl, {:bind, all_pls}

    for pl <- all_pls, do:
      send pl, { :pl_deliver, {:broadcast, max_broadcasts, timeout }, self()}
  end
end
