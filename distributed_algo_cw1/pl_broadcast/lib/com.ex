# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Com do
  def start() do
    receive do
      {:bind, my_pl, pls} ->
        next(my_pl, pls)
    end
  end

  defp next(my_pl, pls) do
    # Create map of peer to {sent, received} messages
    messages = Enum.reduce pls, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end
    receive do
      {:com_forward, {:broadcast, max_broadcasts, timeout}, _} ->
        # Sending timeout message
        Process.send_after(self(), {:timeout}, timeout)
        listen(messages, my_pl, pls, max_broadcasts)
    end
  end

  defp broadcast(pls, my_pl, messages) do
    messages = Enum.reduce pls, messages,
    # Send the pl to different peers
    fn(peer, acc) -> send my_pl, {:pl_send, {:message}, peer};
      {sent, received} = messages[peer];
      # Increment the sent value of map when message is broadcasted
      Map.put(acc, peer, {sent + 1, received})
    end
    messages
  end

  defp listen(messages, my_pl, pls, max_broadcasts) do
    receive do
      {:com_forward, _, pid} ->
        {sent, received} = messages[pid]
        listen(Map.put(messages, pid, {sent, received+1}), my_pl, pls, max_broadcasts)
      # When timeout is reached, output the status of {sent, received} messages
      {:timeout} -> IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      after
        0 ->
          # Continously send the message if the number of messages sent hasn't reached max_broadcasts
          messages = if sent(messages, my_pl) < max_broadcasts, do: broadcast(pls, my_pl, messages), else: messages
          listen(messages, my_pl, pls, max_broadcasts)
      end
  end

  defp sent(messages, my_pl) do
    {sent, _} = messages[my_pl]
    sent
  end
end
