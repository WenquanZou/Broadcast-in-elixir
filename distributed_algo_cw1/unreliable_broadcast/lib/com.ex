# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Com do

  def start(processes) do
    receive do
      {:bind, beb, pid_peer} ->
        next(beb, processes, pid_peer)
    end
  end

  defp next(my_beb, processes, pid_peer) do
    # Create map of peer to {sent, received} messages
    messages = Enum.reduce processes, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end
    receive do
      {:beb_deliver, _, {:beb_broadcast, max_broadcasts, timeout}} ->
        # Sending timeout message
        Process.send_after(self(), {:timeout}, timeout)
        listen(messages, my_beb, max_broadcasts, pid_peer)
    end
  end

  defp broadcast(my_beb, messages) do
    # Ask BEB to broadcast the message
    send my_beb, {:beb_broadcast, {:message}}
    messages = Enum.reduce Map.keys(messages), messages,
    fn(peer, acc) ->
      {sent, received} = messages[peer];
      # Increment the sent value of map when message is broadcasted
      Map.put(acc, peer, {sent + 1, received})
    end
    messages
  end

  defp listen(messages, my_beb, max_broadcasts, pid_peer) do
    receive do
      {:beb_deliver, from, _} ->
        {sent, received} = messages[from]
        listen(Map.put(messages, from, {sent, received+1}), my_beb, max_broadcasts, pid_peer)
      # When timeout is reached, output the status of {sent, received} messages
      {:timeout} -> IO.puts "#{inspect pid_peer}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
    after
      0 ->
        # Continously send the message if the number of messages sent hasn't reached max_broadcasts
        messages = if sent(messages) < max_broadcasts, do: broadcast(my_beb, messages), else: messages
        listen(messages, my_beb, max_broadcasts, pid_peer)
    end
  end

  defp sent(messages) do
    {sent, _} = hd(Map.values(messages))
    sent
  end
end
