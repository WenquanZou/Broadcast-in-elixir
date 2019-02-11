# Yoon Kim (jyk416), Wenquan Zou (wz1816)
defmodule Peer do
  def start broadcast_system do

    pid_com = DAC.node_spawn("", 1, Com, :start, [])
    pid_pl = DAC.node_spawn("", 1, PL, :start, [pid_com])

    send broadcast_system, {:pl_created, pid_pl}
  end
end
