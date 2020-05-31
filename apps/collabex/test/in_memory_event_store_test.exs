defmodule Collabex.InMemoryEventStoreTest do
  use ExUnit.Case, async: true
  alias Collabex.InMemoryEventStore
  alias Collabex.Event

  setup context do
    registry_name = Map.get(context, :registry_name, __MODULE__.Registry)
    start_supervised!({Registry, keys: :unique, name: registry_name})

    {:ok, registry: registry_name}
  end

  defp topic(registry, name), do: {:via, Registry, {registry, name}}

  test "implements events store behaviour", %{registry: registry} do
    topic = topic(registry, "foo")

    assert {:ok, nil} == InMemoryEventStore.last_event(topic)

    assert :ok ==
             InMemoryEventStore.add_event(
               topic(registry, "bar"),
               Event.new(42, {"user1", "red"}, {:insert, [index: 0, text: "foo"]})
             )

    assert :ok ==
             InMemoryEventStore.add_event(
               topic,
               Event.new(1, {"user1", "red"}, {:insert, [index: 0, text: "foo"]})
             )

    assert :ok ==
             InMemoryEventStore.add_event(
               topic,
               Event.new(2, {"user1", "red"}, {:replace, [index: 1, length: 2, text: "fo"]})
             )

    assert :ok ==
             InMemoryEventStore.add_event(
               topic,
               Event.new(3, {"user2", "red"}, {:delete, [index: 0, length: 3]})
             )

    assert {:ok,
            [
              %Event{timestamp: 1},
              %Event{timestamp: 2},
              %Event{timestamp: 3}
            ]} = InMemoryEventStore.replay(topic)

    assert {:ok, %Event{timestamp: 3}} = InMemoryEventStore.last_event(topic)

    assert {:ok,
            [
              %Event{timestamp: 3}
            ]} = InMemoryEventStore.replay(topic, 2)
  end
end
