# Yoon Kim (jyk416), Wenquan Zou (wz1816)
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

    or pl <- all_pls, do:
      send pl, {:bind, all_pls}

    for pl <- all_pls, do:
      send pl, { :pl_deliver, {:broadcast, max_broadcasts, timeout }, self()}
  end

  def waiting_for_connection(no_pls, pls) do
    # If all the PLs are received
    if (length(pls) == no_pls) do
      pls
    else
      receive do
        {:pl_created, pid_pl} ->
          # If not, wait for the signal and add in the current pid_pl to the list pls
          waiting_for_connection(no_pls, pls ++ [pid_pl])
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
