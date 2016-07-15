defmodule ThySupervisor do
  use GenServer

  # API

  def start_link(child_spec_list) do
    GenServer.start_link(__MODULE__, [child_spec_list])
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, pid) do
    GenServer.call(supervisor, {:terminate_child, pid})
  end

  def restart_child(supervisor, pid, child_spec) when is_pid(pid) do
    GenServer.call(supervisor, {:restart_child, pid})
  end

  # Callbacks

  def init([child_spec_list]) do
    Process.flag(:trap_exit, true)
    state = child_spec_list
            |> start_children
            |> Enum.into(HashDict.new)

    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = state |> HashDict.put(pid, child_spec)
        {:reply, {:ok, pid}, new_state}
      :error ->
        {:reply, {:error, "error starting child"}, state}
    end
  end

  def handle_call({:terminate_child, pid}, _from, state) do
    case terminate_child(pid) do
      :ok ->
        new_state = state |> HashDict.delete(pid)
        {:reply, :ok, new_state}
      :error ->
        {:reply, {:error, "error terminating child"}, state}
    end
  end

  def handle_call({:restart_child, old_pid}, _from, state) do
    case HashDict.fetch(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
              new_state = state
                |> HashDict.delete(old_pid)
                |> HashDict.put(pid, child_spec)
              {:reply, {:ok, pid}, new_state}
          :error ->
            {:reply, {:error, "error restarting child"}, state}
        end
      _ ->
        {:reply, :ok, state}
    end
  end


  def handle_info({:EXIT, from, :killed}, state) do
    IO.puts "handle info EXIT"
    new_state = state |> HashDict.delete(from)
    {:noreply, new_state}
  end

  # Private Functions

  def start_children([child_spec|rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec}|start_children(rest)]
      :error ->
        :error
    end
  end

  def start_children([]), do: []


  def start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      pid when is_pid(pid) ->
        {:ok, pid}
      _ ->
        :error
    end
  end

  def terminate_child(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  def restart_child(pid, child_spec) when is_pid(pid) do
    case terminate_child(pid) do
      :ok ->
        case start_child(child_spec) do
          {:ok, new_pid} ->
            {:ok, {new_pid, child_spec}}
          :error ->
            :error
        end
      :error ->
        :error
    end
  end

end
