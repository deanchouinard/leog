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


  test "can be initialized when given child specs" do
    assert {:ok, _} = ThySupervisor.start_link(child_spec_list)
  end

  test "child is created" do
    {:ok, sup_pid} = ThySupervisor.start_link([])
    {:ok, _child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
                        []})
    assert ThySupervisor.count_children(sup_pid) == 1

    #    ThySupervisor.terminate_child(sup_pid, child_pid)

    #assert ThySupervisor.count_children(sup_pid) == 0
    
  end

  test "terminate a child" do
    {:ok, sup_pid} = ThySupervisor.start_link([])
    {:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
                        []})
    snum = ThySupervisor.count_children(sup_pid)

    assert :ok == ThySupervisor.terminate_child(sup_pid, child_pid)
    refute Process.alive?(child_pid)

    enum = ThySupervisor.count_children(sup_pid)

    assert enum == snum - 1
  end

  test "restart child" do
    {:ok, sup_pid} = ThySupervisor.start_link([])
    {:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
                        []})
    old_child_pid = child_pid

    snum = ThySupervisor.count_children(sup_pid)
    
    assert Process.alive?(old_child_pid)
    {:ok, child_pid} = ThySupervisor.restart_child(sup_pid, child_pid, "child_spec")

    refute Process.alive?(old_child_pid)
    enum = ThySupervisor.count_children(sup_pid)

    assert enum == snum
    assert old_child_pid != child_pid
  end

  test "restarts an abnormally terminated child" do
    {:ok, sup_pid} = ThySupervisor.start_link([])
    {:ok, child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
                        []})

    Process.exit(child_pid, :crash)
    refute Process.alive?(child_pid)

    new_child_pid = ThySupervisor.which_children(sup_pid)
                    |> HashDict.keys |> List.first

    assert 1 == ThySupervisor.count_children(sup_pid)
    assert is_pid(new_child_pid)
    assert new_child_pid != child_pid
  end

  test "which_children returns HashDict" do
    {:ok, sup_pid} = ThySupervisor.start_link([])
    {:ok, _child_pid} = ThySupervisor.start_child(sup_pid, {ThyWorker, :start_link,
      []})
    assert is_map(ThySupervisor.which_children(sup_pid))
  end

  defp child_spec_list do
    [
      {ThyWorker, :start_link, []},
      {ThyWorker, :start_link, []},
      {ThyWorker, :start_link, []}
    ]
  end


end
