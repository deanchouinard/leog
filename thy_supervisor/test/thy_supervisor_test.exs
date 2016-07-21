Code.load_file("thy_supervisor.exs", "../lib")

defmodule ThySupervisorTest do
  use ExUnit.Case
  doctest ThySupervisor

  setup do

  end


  test "the truth" do
    assert 1 + 1 == 2
  end
end
