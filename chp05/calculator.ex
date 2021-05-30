defmodule Calculator do
  def start do
    spawn(fn ->
      loop(0)
    end)
  end

  def loop(current_value) do
    receive do
      message -> process_message(current_value, message)
    end
    |> loop
  end

  def add(pid, value) do
    send(pid, {:add, value})
  end

  def minus(pid, value) do
    send(pid, {:minus, value})
  end

  def mul(pid, value) do
    send(pid, {:mul, value})
  end

  def div(pid, value) do
    send(pid, {:div, value})
  end

  def value(pid, caller) do
    send(pid, {:value, caller})
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {operation, value}) do
    case operation do
      :add ->
        current_value + value

      :div ->
        current_value / value

      :mul ->
        current_value * value

      :minus ->
        current_value - value
    end
  end
end

pid = Calculator.start()
send(pid, {:value, self()})

receive do
  value -> value |> IO.inspect()
end

Calculator.add(pid, 100)
Calculator.mul(pid, 2)
Calculator.div(pid, 3)
Calculator.value(pid, self())

receive do
  value -> value |> IO.inspect()
end
