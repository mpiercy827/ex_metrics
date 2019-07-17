defmodule MetricsAgent do
  use Agent

  def start_link() do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def set(values) do
    Agent.update(__MODULE__, fn _ -> values end)
  end
end

Mimic.copy(ExMetrics)
ExUnit.start()
