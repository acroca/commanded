defmodule Commanded.ProcessManagers.ExampleRouter do
  use Commanded.Commands.Router

  alias Commanded.ProcessManagers.{ExampleAggregate,ExampleCommandHandler}
  alias Commanded.ProcessManagers.ExampleAggregate.Commands.{Publish,Start,Stop}

  dispatch [Start,Publish,Stop],
    to: ExampleCommandHandler,
    aggregate: ExampleAggregate,
    identity: :aggregate_uuid
end
