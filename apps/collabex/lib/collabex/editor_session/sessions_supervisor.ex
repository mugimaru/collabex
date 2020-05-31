defmodule Collabex.EditorSession.SessionsSupervisor do
  use DynamicSupervisor

  @spec start_link(term) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(event_store) do
    DynamicSupervisor.start_link(__MODULE__, event_store, name: __MODULE__)
  end

  @impl DynamicSupervisor
  @spec init(any) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(event_store) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [event_store])
  end

  @spec find_or_start_child(Collabex.EditorSession.Session.name()) :: {:error, any} | {:ok, pid}
  def find_or_start_child({:via, Registry, {_registry, _topic}} = name) do
    spec = {Collabex.EditorSession.Session, name}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, term} ->
        {:error, term}
    end
  end

  def find_or_start_child(topic) do
    find_or_start_child({:via, Registry, {Collabex.EditorSession.Registry, topic}})
  end
end
