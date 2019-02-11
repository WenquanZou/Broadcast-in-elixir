# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule RB do
  def start(pid_peer) do
    receive do {:bind, c, beb} -> next pid_peer, c, beb, MapSet.new, 0 end
  end

  defp next pid_peer, c, beb, delivered, uniqID do
    # uniqID is used to keep track of which messages have been sent
    receive do
      {:rb_broadcast, m} ->
        send beb, {:beb_broadcast, {:rb_data, pid_peer, uniqID, m}}
        next pid_peer, c, beb, delivered, uniqID + 1
      {:beb_deliver, _, {:rb_data, sender, _, m} = rb_m} ->
        # If the message was sent before
        if MapSet.member?(delivered, rb_m) do
          next pid_peer, c, beb, delivered, uniqID
        else
          send c, {:rb_deliver, sender, m}
          send beb, {:beb_broadcast, rb_m}
          # If the message was not sent before
          next pid_peer, c, beb, MapSet.put(delivered, rb_m), uniqID + 1
        end
    end
  end

end
