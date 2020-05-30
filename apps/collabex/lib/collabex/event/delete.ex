defmodule Collabex.Event.Delete do
  @derive Jason.Encoder
  defstruct [:index, :length, :text]

  @type t :: %__MODULE__{
          index: pos_integer(),
          length: pos_integer(),
          text: String.t()
        }
end
