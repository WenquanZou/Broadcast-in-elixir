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
    pid_pl = DAC.node_spawn("", 1, LPL, :start, [self()])

    send broadcast_system, {:pl_created, self(), pid_pl}

    receive do
      {:bindAll, pls_map} ->
        send(pid_pl, {:bind, pls_map, beb})
        send(beb, {:bind, pid_pl, pid_com})
        send(pid_com, {:bind, beb, self()})
    end

    receive do
      {:kill_process} ->
        kill_process(pid_com, pid_pl, beb)
        Process.exit(self(), :kill)
    end

  end

  def kill_process(com, pl, beb) do
    Process.exit(com, :kill)
    Process.exit(pl, :kill)
    Process.exit(beb, :kill)
  end
end
