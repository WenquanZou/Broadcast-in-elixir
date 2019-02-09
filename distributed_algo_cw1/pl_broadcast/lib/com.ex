defmodule Com do

  def start() do
    receive do
      {:bind, my_pl, pls} ->
        next(my_pl, pls)
    end
  end

  defp next(my_pl, pls) do
  messages = Enum.reduce pls, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end
    receive do
      {:com_forward, {:broadcast, max_broadcasts, timeout}, _} ->
        Process.send_after(self(), {:timeout}, timeout)
        listen(messages, my_pl, pls, max_broadcasts)
    end
  end

  defp broadcast(pls, my_pl, messages) do
    messages = Enum.reduce pls, messages,
    fn(peer, acc) -> send my_pl, {:pl_send, {:message}, peer};
      {sent, received} = messages[peer];
      Map.put(acc, peer, { sent+1, received})
    end
    messages
  end

  defp listen(messages, my_pl, pls, max_broadcasts) do
    receive do
      { :com_forward, _, pid} ->
        {sent, received} = messages[pid]
        listen(Map.put(messages, pid, {sent, received+1}), my_pl, pls, max_broadcasts)
      {:timeout} -> IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      after
        0 ->
          messages = if sent(messages, my_pl) < max_broadcasts, do: broadcast(pls, my_pl, messages), else: messages
          listen(messages, my_pl, pls, max_broadcasts)
      end
  end

  defp sent(messages, my_pl) do
    {sent, _} = messages[my_pl]
    sent
  end
end
