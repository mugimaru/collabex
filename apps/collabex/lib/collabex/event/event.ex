defmodule Collabex.Event do
  defstruct [:timestamp, :event, :meta]

  alias Collabex.Event

  @type event :: Event.Insert.t() | Event.Delete.t() | Event.Replace.t()

  @type t :: %__MODULE__{
          timestamp: pos_integer(),
          event: event(),
          meta: Event.Meta.t()
        }

  @spec new(
          timestamp :: integer(),
          user_name :: term,
          {:delete, keyword()} | {:insert, keyword()} | {:replace, keyword()}
        ) :: Collabex.Event.t()
  def new(timestamp, user_name, {type, args}) do
    __struct__(
      timestamp: timestamp,
      event: event_args_into_struct({type, args}),
      meta: Collabex.Event.Meta.__struct__(user_name: user_name)
    )
  end

  defp event_args_into_struct({:insert, args}) do
    Collabex.Event.Insert.__struct__(args)
  end

  defp event_args_into_struct({:replace, args}) do
    Collabex.Event.Replace.__struct__(args)
  end

  defp event_args_into_struct({:delete, args}) do
    Collabex.Event.Replace.__struct__(args)
  end
end
