defmodule PL do
  def start() do
    receive do
      {:bind, pls_map, beb} ->
        next(pls_map, beb)
    end
  end
  def next(pls_map, beb) do
    receive do
      {:pl_send, dst_process, msg} ->
        IO.puts "#{DAC.self_string()} send to #{inspect pls_map[dst_process]}"
        send(pls_map[dst_process], {:pl_deliver, dst_process, msg})
      {:pl_deliver, dpt_process, msg} ->
        send(beb, {:pl_deliver, dpt_process, msg})
    end
    next(pls_map, beb)
  end
end
