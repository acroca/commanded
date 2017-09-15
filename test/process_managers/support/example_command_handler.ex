defmodule Commanded.ProcessManagers.ExampleCommandHandler do
  @behaviour Commanded.Commands.Handler

  alias Commanded.ProcessManagers.ExampleAggregate
  alias Commanded.ProcessManagers.ExampleAggregate.Commands.{Publish,Start,Stop}

  def handle(%ExampleAggregate{} = aggregate, %Start{aggregate_uuid: aggregate_uuid}) do
    ExampleAggregate.start(aggregate, aggregate_uuid)
  end

  def handle(%ExampleAggregate{} = aggregate, %Publish{interesting: interesting, uninteresting: uninteresting}) do
    ExampleAggregate.publish(aggregate, interesting, uninteresting)
  end

  def handle(%ExampleAggregate{} = aggregate, %Stop{}) do
    ExampleAggregate.stop(aggregate)
  end
end
