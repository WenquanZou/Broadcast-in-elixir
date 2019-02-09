defmodule Peer do
  def start broadcast_system do
    receive do
      {:bind, peers} ->
        next(broadcast_system, peers)
    end
  end

  def next broadcast_system, peers do
    pid_com = DAC.node_spawn("", 1, Com, :start, [peers])

    beb = DAC.node_spawn("",1, Beb, :start, [peers])
    pid_pl = DAC.node_spawn("", 1, PL, :start, [self()])

    send broadcast_system, {:pl_created, self(), pid_pl}

    receive do
      {:bindAll, pls_map} ->
        send(pid_pl, {:bind, pls_map, beb})
        send(beb, {:bind, pid_pl, pid_com})
        send(pid_com, {:bind, beb, self()})
    end

  end
end
