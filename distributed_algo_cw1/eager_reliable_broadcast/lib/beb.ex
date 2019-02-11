# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Beb do

  def start processes do
    receive do {:bind, pl, rb} -> next processes, pl, rb end
  end

  def next processes, pl, rb do
    receive do
      {:beb_broadcast, msg} ->
        for dest <- processes, do:
          send pl, {:pl_send, dest, msg}
      {:pl_deliver, from, msg} ->
        send rb, {:beb_deliver, from, msg}
    end
    next processes, pl, rb
  end
end
