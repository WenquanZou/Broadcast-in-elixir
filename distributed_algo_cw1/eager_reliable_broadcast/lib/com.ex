# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Com do

  def start(processes) do
    receive do
      {:bind, rb, pid_peer} ->
        next(rb, processes, pid_peer)
    end
  end

  defp next(my_rb, processes, pid_peer) do
    # Create the map of peer_pid to {sent, received}.
    messages = Enum.reduce processes, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end
    receive do
      {:rb_deliver, _, {:rb_broadcast, max_broadcasts, timeout}} ->
        # Send itself timeout signal
        Process.send_after(self(), {:timeout}, timeout)
        listen(messages, my_rb, max_broadcasts, pid_peer)
    end
  end

  defp broadcast(my_rb, messages) do
    # Ask rb to broadcast messages
    send my_rb, {:rb_broadcast, {:message}}
    messages = Enum.reduce Map.keys(messages), messages,
    fn(peer, acc) ->
      {sent, received} = messages[peer];
      Map.put(acc, peer, { sent+1, received})
    end
    messages
  end

  defp listen(messages, my_rb, max_broadcasts, pid_peer) do
    receive do
      {:rb_deliver, from, _} ->
        {sent, received} = messages[from]
        listen(Map.put(messages, from, {sent, received+1}), my_rb, max_broadcasts, pid_peer)
        # When timeout is reached, output the status of {sent, received} messages
        {:timeout} -> IO.puts "#{inspect pid_peer}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
    after
      0 ->
        # Continously send the message if the number of messages sent hasn't reached max_broadcasts
        messages = if sent(messages) < max_broadcasts, do: broadcast(my_rb, messages), else: messages
        listen(messages, my_rb, max_broadcasts, pid_peer)
    end
  end

  defp sent(messages) do
    {sent, _} = hd(Map.values(messages))
    sent
  end
end
