defmodule Collabex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Collabex.PubSub},
      Collabex.InMemoryEventStore.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Collabex.Supervisor)
  end
end
