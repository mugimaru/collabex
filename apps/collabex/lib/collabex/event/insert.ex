defmodule Collabex.Event.Insert do
  @derive Jason.Encoder
  defstruct [:index, :text]

  @type t :: %__MODULE__{
          index: pos_integer(),
          text: String.t()
        }
end
