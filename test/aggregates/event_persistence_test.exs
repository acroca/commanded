defmodule Commanded.Aggregates.EventPersistenceTest do
  use Commanded.StorageCase

  import Commanded.Enumerable, only: [pluck: 2]

  alias Commanded.Aggregates.{Aggregate,AppendItemsHandler,ExampleAggregate}
  alias Commanded.Aggregates.ExampleAggregate.Commands.AppendItems
  alias Commanded.EventStore
  alias Commanded.Helpers.ProcessHelper

  test "should persist pending events in order applied" do
    aggregate_uuid = UUID.uuid4

    {:ok, ^aggregate_uuid} = Commanded.Aggregates.Supervisor.open_aggregate(ExampleAggregate, aggregate_uuid)

    {:ok, 10} = Aggregate.execute(aggregate_uuid, %AppendItems{count: 10}, AppendItemsHandler, :handle)

    recorded_events = EventStore.stream_forward(aggregate_uuid, 0) |> Enum.to_list()

    assert recorded_events |> pluck(:data) |> pluck(:index) == Enum.to_list(1..10)
  end

  test "should reload persisted events when restarting aggregate process" do
    aggregate_uuid = UUID.uuid4

    {:ok, ^aggregate_uuid} = Commanded.Aggregates.Supervisor.open_aggregate(ExampleAggregate, aggregate_uuid)

    {:ok, 10} = Aggregate.execute(aggregate_uuid, %AppendItems{count: 10}, AppendItemsHandler, :handle)

    ProcessHelper.shutdown_aggregate(aggregate_uuid)

    {:ok, ^aggregate_uuid} = Commanded.Aggregates.Supervisor.open_aggregate(ExampleAggregate, aggregate_uuid)

    assert Aggregate.aggregate_version(aggregate_uuid) == 10
    assert Aggregate.aggregate_state(aggregate_uuid) == %ExampleAggregate{
      items: 1..10 |> Enum.to_list(),
      last_index: 10,
    }
  end

  test "should reload persisted events in batches when restarting aggregate process" do
    aggregate_uuid = UUID.uuid4

    {:ok, ^aggregate_uuid} = Commanded.Aggregates.Supervisor.open_aggregate(ExampleAggregate, aggregate_uuid)

    {:ok, 100} = Aggregate.execute(aggregate_uuid, %AppendItems{count: 100}, AppendItemsHandler, :handle)
    {:ok, 200} = Aggregate.execute(aggregate_uuid, %AppendItems{count: 100}, AppendItemsHandler, :handle)
    {:ok, 201} = Aggregate.execute(aggregate_uuid, %AppendItems{count: 1}, AppendItemsHandler, :handle)

    ProcessHelper.shutdown_aggregate(aggregate_uuid)

    {:ok, ^aggregate_uuid} = Commanded.Aggregates.Supervisor.open_aggregate(ExampleAggregate, aggregate_uuid)

    assert Aggregate.aggregate_version(aggregate_uuid) == 201
    assert Aggregate.aggregate_state(aggregate_uuid) == %ExampleAggregate{
      items: 1..201 |> Enum.to_list,
      last_index: 201,
    }
  end
end
