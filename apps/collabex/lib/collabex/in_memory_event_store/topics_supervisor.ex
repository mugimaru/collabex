defmodule Collabex.InMemoryEventStore.TopicsSupervisor do
  use DynamicSupervisor

  @spec start_link(term) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl DynamicSupervisor
  @spec init(any) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def find_or_start_child({:via, Registry, {_registry, _topic}} = name) do
    spec = {Collabex.InMemoryEventStore.TopicServer, name}

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
    topic |> server_name_for_topic() |> find_or_start_child()
  end

  defp server_name_for_topic(topic) do
    {:via, Registry, {Collabex.InMemoryEventStore.Registry, topic}}
  end
end
