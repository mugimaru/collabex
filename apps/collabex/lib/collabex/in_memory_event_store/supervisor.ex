defmodule Collabex.InMemoryEventStore.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    registry_name = Keyword.get(args, :registry_name, Collabex.InMemoryEventStore.Registry)

    children = [
      {Registry, keys: :unique, name: registry_name},
      {Collabex.InMemoryEventStore.TopicsSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
