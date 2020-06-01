defmodule Collabex.EditorSession.Config do
  @derive Jason.Encoder
  defstruct [:mode]

  @type t :: %__MODULE__{
          mode: nil | String.t()
        }
end
