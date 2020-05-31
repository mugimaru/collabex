defmodule Collabex.EditorSession.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    registry_name = Keyword.get(args, :registry_name, Collabex.EditorSession.Registry)
    event_store = Keyword.fetch!(args, :event_store)

    children = [
      {Registry, keys: :unique, name: registry_name},
      {Collabex.EditorSession.SessionsSupervisor, event_store}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
