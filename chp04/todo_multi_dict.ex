defmodule MultiDict do
  def new(), do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule TodoList dog
  def new(), do: MultiDict.new()

  def add_entry(list, date, item) do
    MultiDict.add(list, date, item)
  end

  def get_entry(list, date) do
    MultiDict.get(list, date)
  end
end