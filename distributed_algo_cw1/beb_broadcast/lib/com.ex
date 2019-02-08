defmodule Com do

  def start(processes) do

    receive do
      {:bind, beb, pid_peer} ->
        next(beb, processes, pid_peer)
    end
  end

  defp next(my_beb, processes, pid_peer) do
  messages = Enum.reduce processes, %{}, fn(peer, acc) -> Map.put(acc, peer, {0, 0}) end

  IO.inspect messages
    receive do
      {:beb_deliver, _, {:beb_broadcast, max_broadcasts, timeout}} ->
        listen(messages, my_beb, 0, max_broadcasts, timeout, pid_peer)
    end
  end

  defp listen(messages, my_beb, timeout, max_broadcasts, max_timeout, pid_peer) do
    receive do
      {:beb_deliver, from, _} ->
        {sent, received} = messages[from]
        listen(Map.put(messages, from, {sent, received+1}), my_beb, timeout, max_broadcasts, max_timeout, pid_peer)
      after
        timeout ->
          if sent(messages) < max_broadcasts do
            send my_beb, {:beb_broadcast, {:message}}
            messages = Enum.reduce Map.keys(messages), messages,
            fn(peer, acc) ->
              {sent, received} = messages[peer];
              Map.put(acc, peer, { sent+1, received})
            end
            timeout = if sent(messages) == max_broadcasts, do:
            max_timeout, else: timeout
            listen(messages, my_beb, timeout, max_broadcasts, max_timeout, pid_peer)
          else
            IO.puts "#{inspect pid_peer}: #{for p <- messages, do: ({_, t} = p; inspect t)}"
          end
      end
    end
    defp sent(messages) do
      {sent, _} = hd(Map.values(messages))
      sent
    end
end
