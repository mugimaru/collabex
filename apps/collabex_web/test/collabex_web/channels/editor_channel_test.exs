defmodule CollabexWeb.EditorChannelTest do
  use CollabexWeb.ChannelCase

  @user %Collabex.Event.User{name: "u", color: "red"}

  setup context do
    args = %{user_name: @user.name, user_color: @user.color}
    topic = "topic-#{context[:test]}"

    {:ok, _, socket} =
      CollabexWeb.UserSocket
      |> socket("user_id", %{})
      |> subscribe_and_join(CollabexWeb.EditorChannel, "editors:#{topic}", args)

    %{socket: socket, topic: topic}
  end

  test "replays events on join", %{socket: socket, topic: topic} do
    push(socket, "insert", %{"index" => 0, "text" => "foobar"})

    {:ok, %{events: [event]}, _socket} =
      CollabexWeb.UserSocket
      |> socket("user_id", %{})
      |> subscribe_and_join(CollabexWeb.EditorChannel, "editors:#{topic}", %{
        user_name: "u2",
        user_color: "blue"
      })

    assert %{
             event: %Collabex.Event.Insert{index: 0, text: "foobar"},
             event_type: :insert,
             timestamp: _,
             user: @user
           } = event
  end

  test "handles insert event", %{socket: socket} do
    push(socket, "insert", %{"index" => 0, "text" => "foobar"})

    assert_broadcast "inserted", %{
      event: %Collabex.Event.Insert{index: 0, text: "foobar"},
      event_type: :insert,
      timestamp: _,
      user: @user
    }
  end

  test "handles delete event", %{socket: socket} do
    push(socket, "delete", %{"index" => 0, "length" => 10})

    assert_broadcast "deleted", %{
      event: %Collabex.Event.Delete{index: 0, length: 10},
      event_type: :delete,
      timestamp: _,
      user: @user
    }
  end

  test "handles replace event", %{socket: socket} do
    push(socket, "replace", %{"index" => 0, "length" => 6, "text" => "foobar"})

    assert_broadcast "replaced", %{
      event: %Collabex.Event.Replace{index: 0, length: 6, text: "foobar"},
      event_type: :replace,
      timestamp: _,
      user: @user
    }
  end
end
