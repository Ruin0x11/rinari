defmodule Rinari.Request.PageRequest do
  defstruct genre: nil, keywords: nil, sort: nil, order: nil

  @type t :: %__MODULE__{genre: binary, keywords: binary, sort: binary, order: binary}
end
