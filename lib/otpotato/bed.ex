defmodule OTPotato.Bed do
  @moduledoc """
  A bed is a rectangular area of ground, with a top-left origin (x, y), a width w in metres and a length l in metres.

  A given bed is assumed to have a single soil type.

  Beds may be adjacent, but should not overlap.

  Once added to the application, a bed will be known by some identifier.
  """

  use Ecto.Schema

  alias Ecto.Changeset

  @soil_types OTPotato.Consts.soil_types()

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :origin_x, :origin_y, :length, :width, :soil_type]}
  schema "beds" do
    field :origin_x, :integer
    field :origin_y, :integer
    field :length, :decimal
    field :width, :decimal
    field :soil_type, Ecto.Enum, values: @soil_types
    belongs_to :garden, OTPotato.Garden, type: Ecto.UUID
  end

  @fields [:origin_x, :origin_y, :length, :width, :soil_type]
  def changeset(changeset, attrs) do
    changeset
    |> Changeset.cast(attrs, @fields)
    |> Changeset.validate_required(@fields)
    |> Changeset.validate_number(:length, greater_than: 0)
    |> Changeset.validate_number(:width, greater_than: 0)
    |> Changeset.validate_inclusion(:soil_type, @soil_types)
  end
end
