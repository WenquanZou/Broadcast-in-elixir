defmodule PL do
  def start(com) do
    receive do
      {:bind, pls} ->
      send(com, {:bind, self(), pls})
      next(com)
    end
  end
  def next(com) do
    receive do
      {:pl_send, msg, dst} -> send(dst, {:pl_deliver, msg, self()})
      {:pl_deliver, msg, dpt} -> send(com, {:com_forward, msg, dpt})
    end
    next(com)
  end
end
