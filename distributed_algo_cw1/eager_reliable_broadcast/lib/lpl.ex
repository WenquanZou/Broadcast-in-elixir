# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule LPL do
  def start(pid_peer) do
    receive do
      {:bind, pls_map, beb} ->
        next(pls_map, beb, pid_peer)
    end
  end
  def next(pls_map, beb, pid_peer) do
    reliability = 50
    receive do
      {:pl_send, dst_process, msg} ->
        # Simulate unreliable messages sending
        if (DAC.random(100) <= reliability) do
          send(pls_map[dst_process], {:pl_deliver, pid_peer, msg})
        end
      {:pl_deliver, dpt_process, msg} ->
        send(beb, {:pl_deliver, dpt_process, msg})
    end
    next(pls_map, beb, pid_peer)
  end
end
