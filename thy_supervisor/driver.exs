{:ok, sup_pid} = ThySupervisor.start_link([])

{:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
  []})

IO.inspect Process.info(sup_pid, :links)

IO.puts "self: #{inspect self}"

ThySupervisor.terminate_child(child_pid)
:timer.sleep(500)
IO.inspect Process.info(sup_pid, :links)

