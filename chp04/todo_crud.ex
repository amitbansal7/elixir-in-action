require Logger

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    entries
    |> Enum.reduce(%TodoList{}, fn entry, acc -> add_entry(acc, entry) end)
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )
    %TodoList{
      todo_list | entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |>Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list
      {:ok, old_entry} ->
        id = old_entry.id
        new_entry = %{id: ^id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %TodoList{
          todo_list | entries: new_entries,
        }
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, func) do
    todo_list.entries |> Enum.flat_map_reduce(todo_list, fn {id, entry}, acc ->
      if func.(entry) do
        {[id], pop_in(acc.entries[id]) |> elem(1)}
      else
        {[], acc}
      end
    end) |> elem(1)
  end
end

entries = [
  %{date: ~D[2018-12-19], title: "Dentist"},
  %{date: ~D[2018-12-20], title: "Shopping"},
  %{date: ~D[2018-12-19], title: "Movies"}
]
list = TodoList.new(entries)
list = TodoList.add_entry(list, %{date: ~D[2018-12-21], title: "Elixir"})
list |> inspect() |> Logger.debug()
TodoList.delete_entry(list, fn entry -> entry.date == ~D[2018-12-19] end) |> inspect() |> Logger.debug()
