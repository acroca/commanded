defmodule Commanded.Event.AppendingEventHandler do
  @moduledoc false
  use Commanded.Event.Handler, name: __MODULE__

  def init do
    with {:ok, _pid} <- Agent.start_link(fn -> %{events: [], metadata: []} end, name: __MODULE__) do
      :ok
    end
  end

  def handle(event, event_metadata) do
    Agent.update(__MODULE__, fn %{events: events, metadata: metadata} ->
      %{events: events ++ [event], metadata: metadata ++ [event_metadata]}
    end)
  end

  def received_events do
    Agent.get(__MODULE__, fn %{events: events} -> events end)
  end

  def received_metadata do
    Agent.get(__MODULE__, fn %{metadata: metadata} -> metadata end)
  end
end
