# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule PL do
  def start(pid_peer) do
    receive do
      {:bind, pls_map, beb} ->
        next(pls_map, beb, pid_peer)
    end
  end
  
  def next(pls_map, beb, pid_peer) do
    receive do
      {:pl_send, dst_process, msg} ->
        send(pls_map[dst_process], {:pl_deliver, pid_peer, msg})
      {:pl_deliver, dpt_process, msg} ->
        send(beb, {:pl_deliver, dpt_process, msg})
    end
    next(pls_map, beb, pid_peer)
  end
end
