{:ok, sup_pid} = ThySupervisor.start_link([])

{:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
  []})

IO.inspect Process.info(sup_pid, :links)

IO.puts "self: #{inspect self}"

ThySupervisor.terminate_child(sup_pid, child_pid)
:timer.sleep(500)
IO.inspect Process.info(sup_pid, :links)

IO.puts "\n### Restart Child"
{:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
  []})
IO.puts "Child pid: #{inspect child_pid}"
:timer.sleep(500)
IO.inspect Process.info(sup_pid, :links)
ThySupervisor.restart_child(sup_pid, child_pid, {ThyWorker, :start_link, []})
:timer.sleep(500)
IO.inspect Process.info(sup_pid, :links)

IO.puts "Count children: #{inspect ThySupervisor.count_children(sup_pid)}"
IO.puts "Which children: #{inspect ThySupervisor.which_children(sup_pid)}"

