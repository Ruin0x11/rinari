defmodule Rinari.Model.Category do
  use Rinari.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "categories" do
    field :name, :string
    field :provider_id, :integer
    field :torrent_provider_id, :id

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:provider_id, :name])
    |> validate_required([:provider_id, :name])
  end
end
