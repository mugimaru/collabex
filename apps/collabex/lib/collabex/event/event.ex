defmodule Collabex.Event do
  defstruct [:timestamp, :event, :user]

  alias Collabex.Event

  @type event :: Event.Insert.t() | Event.Delete.t() | Event.Replace.t()

  @type t :: %__MODULE__{
          timestamp: integer(),
          event: event(),
          user: Event.User.t()
        }

  @spec new(
          timestamp :: integer(),
          user :: Collabex.Event.User.t(),
          {:delete, keyword()} | {:insert, keyword()} | {:replace, keyword()}
        ) :: Collabex.Event.t()
  def new(timestamp, user, {type, args}) do
    __struct__(
      timestamp: timestamp,
      event: event_args_into_struct({type, args}),
      user: user
    )
  end

  defp event_args_into_struct({:insert, args}) do
    Collabex.Event.Insert.__struct__(args)
  end

  defp event_args_into_struct({:replace, args}) do
    Collabex.Event.Replace.__struct__(args)
  end

  defp event_args_into_struct({:delete, args}) do
    Collabex.Event.Delete.__struct__(args)
  end
end
