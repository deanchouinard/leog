defmodule Cache do
  use GenServer

  @name CA

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: CA] )
  end

  def write(key, value) do
    GenServer.cast(@name, {:write, {key, value}})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def exist?(key) do
    GenServer.call(@name, key)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect stats
    :ok
  end

  # def handle_call({:location, location}, _from, stats) do
  #   case temperature_of(location) do
  #     {:ok, temp} ->
  #       new_stats = update_stats(stats, location)
  #       {:reply, "#{temp} F", new_stats}
  #
  #     _ ->
  #       {:reply, :error, stats}
  #   end
  # end

  def handle_call({:read, key}, _from, cache) do
    case Map.has_key?(cache, key) do
      true ->
        {:reply, Map.get(cache, key), cache}
      false ->
        {:reply, :error, cache}
    end
  end

  def handle_cast({:write, {key, value}}, cache) do
    new_cache = update_cache(cache, key, value)
    {:noreply, new_cache}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  ## Helper Functions

  defp update_cache(old_cache, key, value) do
    case Map.has_key?(old_cache, key) do
      true ->
        Map.update!(old_cache, key, value)
      false ->
        Map.put_new(old_cache, key, value)
    end
  end

end

{:ok, pid} = Cache.start_link
Cache.write(:stooges, ["Larry", "Moe", "Curly"])
IO.inspect Cache.read(:stooges)

