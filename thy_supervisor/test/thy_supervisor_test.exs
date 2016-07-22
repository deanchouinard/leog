Code.load_file("thy_supervisor.ex", "lib")
Code.load_file("thy_worker.ex", "lib")
Code.load_file("test_helper.exs", "test")

ExUnit.configure exclude: :pending, trace: true

defmodule ThySupervisorTest do
  use ExUnit.Case
  #  doctest ThySupervisor

  setup do
    {:ok, sup_pid} = ThySupervisor.start_link([])

    {:ok, sup_pid: sup_pid}
  end


  test "the truth" do
    assert 1 + 1 == 2
  end

  test "child is created", context do
    {:ok, child_pid} = ThySupervisor.start_child(context[:sup_pid], {ThyWorker, :start_link,
                        []})
    assert ThySupervisor.count_children(context[:sup_pid]) == 1

    #    ThySupervisor.terminate_child(sup_pid, child_pid)

    #assert ThySupervisor.count_children(sup_pid) == 0
    
  end

  test "terminate a child", context do

    {:ok, child_pid} = ThySupervisor.start_child(context[:sup_pid], {ThyWorker, :start_link,
                        []})
    snum = ThySupervisor.count_children(context[:sup_pid])

    ThySupervisor.terminate_child(context[:sup_pid], child_pid)

    enum = ThySupervisor.count_children(context[:sup_pid])

    assert enum == snum - 1
  end

  test "restart child", context do

    {:ok, child_pid} = ThySupervisor.start_child(context[:sup_pid], {ThyWorker, :start_link,
                        []})
    old_child_pid = child_pid

    snum = ThySupervisor.count_children(context[:sup_pid])

    {:ok, child_pid} = ThySupervisor.restart_child(context[:sup_pid], child_pid, "child_spec")

    enum = ThySupervisor.count_children(context[:sup_pid])

    assert enum == snum
    assert old_child_pid != child_pid
  end

  test "which_children returns HashDict", context do
    assert is_map(ThySupervisor.which_children(context[:sup_pid]))
  end


end
