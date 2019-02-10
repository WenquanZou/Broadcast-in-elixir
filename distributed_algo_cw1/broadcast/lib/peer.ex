defmodule Peer do

  def start do

    IO.puts ["Create peer at ", DAC.self_string()]
    receive do
      {:bind, neighbours} ->
        next neighbours
    end
  end

  defp next(neighbours) do
  messages = Enum.reduce neighbours, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end

    receive do
      {:broadcast, max_broadcasts, timeout} ->
        Process.send_after(self(), {:timeout}, timeout)
        listen(messages, neighbours, max_broadcasts)
    end
  end

  defp broadcast(nodes, messages) do
    messages = Enum.reduce nodes, messages,
    fn(peer, acc) -> send peer, {:message, self()};
      {sent, received} = messages[peer];
      Map.put(acc, peer, { sent+1, received})
    end
    messages
  end

  defp listen(messages, nodes, max_broadcasts) do
    receive do
      { :message, pid} ->
        {sent, received} = messages[pid]
        listen(Map.put(messages, pid, {sent, received+1}), nodes, max_broadcasts)
      {:timeout} -> IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      after
        0 ->
          messages = if sent(messages) < max_broadcasts, do: broadcast(nodes, messages), else: messages
          listen(messages, nodes, max_broadcasts)
      end
    end
    defp sent(messages) do
      {sent, _} = messages[self()]
      sent
    end
end
