defmodule Collabex.EventStore do
  @type topic :: term

  @callback add_event(topic(), Collabex.Event.t()) :: :ok | {:error, term}
  @callback replay(topic()) :: {:ok, [Collabex.Event.t()]} | {:error, term}
  @callback replay(topic(), after_timestamp :: integer()) ::
              {:ok, [Collabex.Event.t()]} | {:error, term}
  @callback last_event(topic()) :: {:ok, nil | Collabex.Event.t()} | {:error, term}
end
