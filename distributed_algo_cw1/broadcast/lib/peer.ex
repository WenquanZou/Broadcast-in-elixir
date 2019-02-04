defmodule Peer do

  def start do
    receive do 
      {:bind, neighbours} -> next neighbours
    end
  end

  defp next neighbours do
    receive do 
      {:broadcast, max_broadcasts, timeout} -> 
    # TODO
    end
  end
end
