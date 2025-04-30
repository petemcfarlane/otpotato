defmodule OTPotato.Plant do
  @moduledoc """
  Represents a plant in our garden. Plant names must be unique
  """
  use Ecto.Schema

  @soil_types OTPotato.Consts.soil_types()

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :name, :soil_types, :benefits_from]}
  schema "plants" do
    field :name, :string
    field :soil_types, {:array, Ecto.Enum}, values: @soil_types
    field :benefits_from, {:array, :string}
  end
end
