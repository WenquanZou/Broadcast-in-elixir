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

  IO.inspect messages
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        timer = Process.send_after(self(), {:timeout}, timeout)
        listen(messages, neighbours, 0, max_broadcasts, timeout, timer)
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

  defp listen(messages, nodes, time, max_broadcasts, timeout, timer) do
    receive do
      { :message, pid} ->
        {sent, received} = messages[pid]
        listen(Map.put(messages, pid, {sent, received+1}), nodes, time, max_broadcasts, timeout, timer)
      {:timeout} -> IO.puts "#{DAC.self_string()}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
      after
        0 ->
          messages = if sent(messages) < max_broadcasts, do: broadcast(nodes, messages), else: messages
          listen(messages, nodes, time, max_broadcasts, timeout, timer)
      end
    end
    defp sent(messages) do
      {sent, _} = messages[self()]
      sent
    end
end
