defmodule Commanded.Helpers.ProcessHelper do
  @moduledoc false  
  import ExUnit.Assertions

  alias Commanded.Aggregates.Aggregate
  alias Commanded.Registration
  alias Commanded.Helpers.Wait

  @doc """
  Stop the given process
  """
  def shutdown(pid) when is_pid(pid) do
    Process.unlink(pid)
    Process.exit(pid, :shutdown)

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5_000
  end

  @doc """
  Stop a given aggregate process
  """
  def shutdown_aggregate(aggregate_uuid) do
    name = {Aggregate, aggregate_uuid}

    Registration.whereis_name(name) |> shutdown()

    # wait until process removed from registry
    Wait.until(fn ->
      assert Registration.whereis_name(name) == :undefined
    end)
  end
end
