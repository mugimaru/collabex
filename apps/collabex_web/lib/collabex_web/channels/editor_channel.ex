defmodule CollabexWeb.EditorChannel do
  use CollabexWeb, :channel
  alias Collabex.Event
  alias Event.User
  alias Collabex.EditorSession

  @impl true
  def join("editors:" <> topic, %{"user_name" => user_name, "user_color" => color}, socket) do
    with :ok <- EditorSession.subscribe(topic),
         {:ok, user} <- EditorSession.join(topic, %User{name: user_name, color: color}),
         {:ok, event_store} <- EditorSession.event_store(topic),
         {:ok, users} <- EditorSession.list_users(topic) do
      socket =
        socket
        |> assign(:topic, topic)
        |> assign(:user, user)
        |> assign(:event_store, event_store)

      {:ok, events} = event_store.replay(topic)

      {:ok, %{users: users, events: Enum.map(events, &encode_event/1)}, socket}
    else
      {:error, reason} ->
        {:error, %{reason: reason}, socket}
    end
  end

  def join(_channel, _args, _socket) do
    {:error, %{error: "unmatched topic"}}
  end

  @impl true
  def handle_in("insert", %{"index" => index, "text" => text}, socket) do
    event = Event.new(now(), socket.assigns[:user], {:insert, index: index, text: text})

    :ok = socket.assigns[:event_store].add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "inserted", encode_event(event))
    {:noreply, socket}
  end

  def handle_in("replace", %{"index" => index, "length" => length, "text" => text}, socket) do
    event = Event.new(now(), socket.assigns[:user], {:replace, index: index, text: text, length: length})

    :ok = socket.assigns[:event_store].add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "replaced", encode_event(event))
    {:noreply, socket}
  end

  def handle_in("delete", %{"index" => index, "length" => length}, socket) do
    event = Event.new(now(), socket.assigns[:user], {:delete, index: index, length: length})
    :ok = socket.assigns[:event_store].add_event(socket.assigns[:topic], event)

    broadcast_from!(socket, "deleted", encode_event(event))
    {:noreply, socket}
  end

  @impl true
  def handle_info({EditorSession, [:user_joined, %Collabex.Event.User{} = user]}, socket) do
    push(socket, "user_joined", %{user: user})
    {:noreply, socket}
  end

  def handle_info({EditorSession, [:user_left, %Collabex.Event.User{} = user]}, socket) do
    push(socket, "user_left", %{user: user})
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, %{assigns: %{topic: topic, user: user}}) do
    EditorSession.leave(topic, user)
  end

  defp encode_event(%Event{event: event, user: user, timestamp: ts}) do
    %{timestamp: ts, event: event, event_type: event_type(event), user: user}
  end

  defp event_type(%Event.Insert{}), do: :insert
  defp event_type(%Event.Replace{}), do: :replace
  defp event_type(%Event.Delete{}), do: :delete

  defp now, do: System.system_time(:nanosecond)
end
