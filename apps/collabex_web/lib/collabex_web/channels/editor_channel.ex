defmodule CollabexWeb.EditorChannel do
  use CollabexWeb, :channel

  @event_store Collabex.InMemoryEventStore

  @impl true
  def join("editors:" <> topic, %{"user_name" => user_name, "user_color" => color}, socket) do
    socket =
      socket
      |> assign(:topic, topic)
      |> assign(:user, %Collabex.Event.User{name: user_name, color: color})

    {:ok, events} = @event_store.replay(topic)

    {:ok, %{events: Enum.map(events, &encode_event/1)}, socket}
  end

  def join(_channel, _args, _socket) do
    {:error, %{error: "unmatched topic"}}
  end

  @impl true
  def handle_in("insert", %{"index" => index, "text" => text}, socket) do
    event =
      Collabex.Event.new(
        now(),
        socket.assigns[:user],
        {:insert, index: index, text: text}
      )

    :ok = @event_store.add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "inserted", encode_event(event))
    {:noreply, socket}
  end

  def handle_in("replace", %{"index" => index, "length" => length, "text" => text}, socket) do
    event =
      Collabex.Event.new(
        now(),
        socket.assigns[:user],
        {:replace, index: index, text: text, length: length}
      )

    :ok = @event_store.add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "replaced", encode_event(event))
    {:noreply, socket}
  end

  def handle_in("delete", %{"index" => index, "length" => length}, socket) do
    event =
      Collabex.Event.new(
        now(),
        socket.assigns[:user],
        {:delete, index: index, length: length}
      )

    :ok = @event_store.add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "deleted", encode_event(event))
    {:noreply, socket}
  end

  defp encode_event(%Collabex.Event{event: event, user: user, timestamp: ts}) do
    %{timestamp: ts, event: event, event_type: event_type(event), user: user}
  end

  defp event_type(%Collabex.Event.Insert{}), do: :insert
  defp event_type(%Collabex.Event.Replace{}), do: :replace
  defp event_type(%Collabex.Event.Delete{}), do: :delete

  defp now, do: System.system_time(:nanosecond)
end
