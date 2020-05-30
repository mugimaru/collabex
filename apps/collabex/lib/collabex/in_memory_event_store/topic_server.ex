defmodule Collabex.InMemoryEventStore.TopicServer do
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> [] end, name: name)
  end

  @spec add_event(pid, Collabex.Event.t()) :: :ok | {:error, struct()}
  def add_event(pid, %Collabex.Event{} = e) do
    with :ok <- Agent.update(pid, &[e | &1]) do
      :ok
    end
  rescue
    e ->
      {:error, e}
  end

  @spec replay(pid) :: {:ok, [Collabex.Event.t()]} | {:error, struct()}
  @spec replay(pid, after_ts :: pos_integer()) :: {:ok, [Collabex.Event.t()]} | {:error, struct()}

  def replay(pid) do
    events = Agent.get(pid, & &1)
    {:ok, Enum.reverse(events)}
  rescue
    e ->
      {:error, e}
  end

  def replay(pid, after_ts) do
    with {:ok, events} <- replay(pid) do
      {:ok, Enum.filter(events, fn %Collabex.Event{timestamp: ts} -> ts > after_ts end)}
    end
  rescue
    e ->
      {:error, e}
  end

  @spec last_event(pid) :: {:ok, nil | Collabex.Event.t()} | {:error, struct()}
  def last_event(pid) do
    last_event =
      Agent.get(pid, fn
        [] -> nil
        st -> hd(st)
      end)

    {:ok, last_event}
  rescue
    e ->
      {:error, e}
  end
end
