defmodule TodoServer do
  def start do
    spawn(fn ->
      loop(TodoList.new())
    end)
  end

  defp loop(todo_list) do
    receive do
      {:add_entry, new_entry} ->
        process_message(todo_list, {:add_entry, new_entry})

      {:entries, caller, date} ->
        process_message(todo_list, {:entries, caller, date})
    end
    |> loop()
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry.date, new_entry)
  end
end

defmodule TodoList do
  def new(), do: %{}

  def add_entry(todo_list, date, title) do
    Map.update(todo_list, date, [title], fn titles -> [title | titles] end)
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end

defmodule TodoClient do
  def start do
    TodoServer.start()
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end
end

todo_server = TodoClient.start()

TodoClient.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Dentist"}
)

TodoClient.add_entry(
  todo_server,
  %{date: ~D[2018-12-20], title: "Shopping"}
)

TodoClient.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Movies"}
)

TodoClient.entries(todo_server, ~D[2018-12-19]) |> IO.inspect()

TodoClient.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Movies 2"}
)

TodoClient.entries(todo_server, ~D[2018-12-19]) |> IO.inspect()
