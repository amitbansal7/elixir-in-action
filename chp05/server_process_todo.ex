defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        loop(callback_module, new_state)
    end
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

defmodule TodoServer do
  def start do
    ServerProcess.start(__MODULE__)
  end

  def init() do
    TodoList.new()
  end

  def add_entry(pid, new_entry) do
    ServerProcess.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def handle_call({:entries, date}, state) do
    {TodoList.entries(state, date), state}
  end

  def handle_cast({:add_entry, new_entry}, state) do
    TodoList.add_entry(state, new_entry.date, new_entry.title)
  end
end

todo_server = TodoServer.start()

TodoServer.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Dentist"}
)

TodoServer.add_entry(
  todo_server,
  %{date: ~D[2018-12-20], title: "Shopping"}
)

TodoServer.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Movies"}
)
|> IO.inspect()

TodoServer.entries(todo_server, ~D[2018-12-19]) |> IO.inspect()

TodoServer.add_entry(
  todo_server,
  %{date: ~D[2018-12-19], title: "Movies 2"}
)

TodoServer.entries(todo_server, ~D[2018-12-19]) |> IO.inspect()
