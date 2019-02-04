defmodule Peer do

  def start do

    IO.puts ["Create peer at ", DAC.self_string()]
    receive do 
      {:bind, neighbours} -> next neighbours
    end
  end

  defp next neighbours do
  message = "Hello, world."
    receive do 
      {:broadcast, max_broadcasts, timeout} -> 
        for dest <- neighbours, do:
          IO.puts ["Sending message from ", DAC.self_string()]
    end
  end
end
