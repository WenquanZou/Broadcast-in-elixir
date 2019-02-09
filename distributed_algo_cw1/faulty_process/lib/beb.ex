defmodule Beb do

  def start processes do
    receive do {:bind, pl, com} -> next processes, pl, com end
  end

  def next processes, pl, com do
    receive do
      {:beb_broadcast, msg} ->
        for dest <- processes, do:
          send pl, {:pl_send, dest, msg}
      {:pl_deliver, from, msg} ->
        send com, {:beb_deliver, from, msg}
    end
    next processes, pl, com
  end
end
