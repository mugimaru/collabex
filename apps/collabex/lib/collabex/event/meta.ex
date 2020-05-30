defmodule Collabex.Event.Meta do
  defstruct [:user_name]

  @type t :: %__MODULE__{
          user_name: String.t()
        }
end
