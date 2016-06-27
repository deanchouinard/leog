defmodule Ping do
  def loop(count \\ 0) do
    receive do
      {pong_pid, :ping} ->
        IO.puts "Ping: #{count}"
        count = count + 1
        send pong_pid, {self(), :pong}
    end
    loop(count)
  end

end

defmodule Pong do
  def loop(count \\ 0) do
    receive do
      {ping_pid, :pong} ->
        IO.puts "Pong: #{count}"
        count = count + 1
        send ping_pid, {self(), :ping}
    end
    loop(count)
  end
end

ping_pid = spawn(Ping, :loop, [])

pong_pid = spawn(Pong, :loop, [])

send(ping_pid, {pong_pid, :ping})

# give the processes a chance to send each other messages...
:timer.sleep(1000)

