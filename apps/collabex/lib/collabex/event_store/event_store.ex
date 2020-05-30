defmodule Collabex.EventStore do
  @type topic :: term

  @callback add_event(topic(), Collabex.Event.t()) :: :ok | {:error, term}
  @callback replay(topic()) :: {:ok, [Event.t()]} | {:error, term}
  @callback replay(topic(), after_timestamp :: pos_integer()) ::
              {:ok, [Event.t()]} | {:error, term}
  @callback last_event(topic()) :: {:ok, nil | Event.t()} | {:error, term}
end
