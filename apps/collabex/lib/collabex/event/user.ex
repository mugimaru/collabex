defmodule Collabex.Event.User do
  @derive Jason.Encoder
  defstruct [:name, :color]

  @type t :: %__MODULE__{
          name: String.t(),
          color: String.t()
        }
end
