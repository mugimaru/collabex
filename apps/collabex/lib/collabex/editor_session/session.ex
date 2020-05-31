defmodule Collabex.EditorSession.Session do
  use GenServer
  alias Collabex.Event.User

  defstruct [:event_store, :users]

  @type state :: %__MODULE__{
          event_store: Collabex.EventStore.t(),
          users: [Collabex.Event.User.t()]
        }

  @type name :: atom | {atom, any} | {:via, atom, any}
  @type id :: pid | name

  @spec start_link(Collabex.EventStore.t(), name()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(event_store, name) do
    GenServer.start_link(__MODULE__, [event_store: event_store], name: name)
  end

  @spec init(keyword) :: {:ok, state()}
  def init(args) do
    event_store = Keyword.fetch!(args, :event_store)

    {:ok, __struct__(event_store: event_store, users: [])}
  end

  @spec join(id(), User.t()) :: {:ok, User.t()}
  def join(pid, user) do
    GenServer.call(pid, {:join, user})
  end

  @spec leave(id(), User.t()) :: {:ok, User.t()}
  def leave(pid, user) do
    GenServer.call(pid, {:leave, user})
  end

  @spec list_users(id()) :: {:ok, [User.t()]}
  def list_users(pid) do
    GenServer.call(pid, :list_users)
  end

  @spec event_store(id()) :: {:ok, Collabex.EventStore.t()}
  def event_store(pid) do
    GenServer.call(pid, :event_store)
  end

  def handle_call(:event_store, _from, st) do
    {:reply, {:ok, st.event_store}, st}
  end

  def handle_call({:join, user}, _from, st) do
    {:reply, {:ok, user}, %{st | users: [user | st.users]}}
  end

  def handle_call({:leave, user}, _from, st) do
    {:reply, {:ok, user}, %{st | users: List.delete(st.users, user)}}
  end

  def handle_call(:list_users, _from, st) do
    {:reply, {:ok, st.users}, st}
  end
end
