defmodule KeyValueStore do
  use GenServer

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def start do
    GenServer.start(KeyValueStore, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end

{:ok, pid} = KeyValueStore.start()
KeyValueStore.put(pid, :some, 12)
IO.puts(KeyValueStore.get(pid, :some))
