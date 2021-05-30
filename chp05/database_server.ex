defmodule DatabaseServer do
  def start do
    spawn(fn ->
      connection = :rand.uniform(1000)
      loop(connection)
    end)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(connection) do
    receive do
      {:run_query, caller, query_def} ->
        send(caller, {:query_result, run_query(query_def, connection)})
    end

    loop(connection)
  end

  defp run_query(query_def, connection) do
    Process.sleep(100)
    "Connection #{connection} : #{query_def} result"
  end
end

server_pid = DatabaseServer.start()
DatabaseServer.run_async(server_pid, "query 1")
DatabaseServer.run_async(server_pid, "query 2")
DatabaseServer.run_async(server_pid, "query 3")

IO.puts DatabaseServer.get_result()
IO.puts DatabaseServer.get_result()
IO.puts DatabaseServer.get_result()

pool = Enum.map(1..100, fn _ -> DatabaseServer.start() end)

Enum.each(
  1..10,
  fn query_id ->
    server_pid = Enum.at(pool, :random.uniform(100) - 1)
    DatabaseServer.run_async(server_pid, "query #{query_id}")
  end
)

Enum.each(1..10, fn _ -> IO.puts(DatabaseServer.get_result()) end)
