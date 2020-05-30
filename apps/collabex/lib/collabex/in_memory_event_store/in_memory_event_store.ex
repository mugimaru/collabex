defmodule Collabex.InMemoryEventStore do
  alias Collabex.{Event, EventStore}
  alias Collabex.InMemoryEventStore.{TopicsSupervisor, TopicServer}
  @behaviour EventStore

  @type topic :: EventStore.topic() | {:via, Registry, {module(), EventStore.topic()}}

  @impl true
  @spec add_event(topic(), Event.t()) :: :ok | {:error, any}
  def add_event(topic, %Event{} = event) do
    with {:ok, pid} <- TopicsSupervisor.find_or_start_child(topic) do
      TopicServer.add_event(pid, event)
    end
  end

  @impl true
  @spec replay(topic()) :: {:ok, [Event.t()]} | {:error, any}
  def replay(topic) do
    with {:ok, pid} <- TopicsSupervisor.find_or_start_child(topic) do
      TopicServer.replay(pid)
    end
  end

  @impl true
  @spec replay(topic(), after_ts :: pos_integer()) ::
          {:ok, [Event.t()]} | {:error, any}
  def replay(topic, after_ts) do
    with {:ok, pid} <- TopicsSupervisor.find_or_start_child(topic) do
      TopicServer.replay(pid, after_ts)
    end
  end

  @impl true
  @spec last_event(topic()) :: {:ok, Event.t() | nil} | {:error, any}
  def last_event(topic) do
    with {:ok, pid} <- TopicsSupervisor.find_or_start_child(topic) do
      TopicServer.last_event(pid)
    end
  end
end
