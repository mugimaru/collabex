defmodule Collabex.EditorSession do
  alias Collabex.{EventStore, Event}
  alias Collabex.EditorSession.{SessionsSupervisor, Session}

  @spec event_store(EventStore.topic()) :: {:ok, EventStore.t()}
  def event_store(topic) do
    with {:ok, pid} <- SessionsSupervisor.find_or_start_child(topic) do
      Session.event_store(pid)
    end
  end

  @spec join(EventStore.topic(), Event.User.t()) ::
          {:ok, %{config: Collabex.EditorSession.Config.t(), users: [User.t()]}}
  def join(topic, user) do
    with {:ok, pid} <- SessionsSupervisor.find_or_start_child(topic),
         {:ok, user} <- Session.join(pid, user) do
      broadcast_event(topic, [:user_joined, user])
      {:ok, user}
    end
  end

  @spec leave(EventStore.topic(), Event.User.t()) :: {:ok, Event.User.t()}
  def leave(topic, user) do
    with {:ok, pid} <- SessionsSupervisor.find_or_start_child(topic),
         {:ok, user} <- Session.leave(pid, user) do
      broadcast_event(topic, [:user_left, user])
      {:ok, user}
    end
  end

  @spec list_users(EventStore.topic()) :: {:ok, [Event.User.t()]}
  def list_users(topic) do
    with {:ok, pid} <- SessionsSupervisor.find_or_start_child(topic) do
      Session.list_users(pid)
    end
  end

  @spec put_config(EventStore.topic(), key :: atom, value :: term) :: {:ok, Collabex.EditorSession.Config.t()}
  def put_config(topic, key, value) when key in [:mode] do
    with {:ok, pid} <- SessionsSupervisor.find_or_start_child(topic) do
      Session.put_config(pid, key, value)
    end
  end

  @spec subscribe(EventStore.topic()) :: :ok | {:error, term}
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Collabex.PubSub, pubsub_topic(topic))
  end

  defp broadcast_event(topic, event) do
    Phoenix.PubSub.broadcast(Collabex.PubSub, pubsub_topic(topic), {__MODULE__, event})
  end

  defp pubsub_topic(topic) do
    "editor_session_manager:#{topic}"
  end
end
