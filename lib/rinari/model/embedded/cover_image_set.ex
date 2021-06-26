defmodule Rinari.Model.Embedded.CoverImageSet do
  use Rinari.Schema

  @derive {Jason.Encoder, except: [:__meta__, :id]}
  embedded_schema do
    field :poster, :string
    field :fanart, :string
    field :banner, :string
  end
end
