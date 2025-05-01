defmodule OTPotato.PlantingPlanEntry do
  use Ecto.Schema

  alias OTPotato.{PlantingPlan, Plant, Bed}
  alias Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:bed_id, :plant_id, :area]}
  schema "planting_plan_entries" do
    belongs_to :planting_plan, PlantingPlan, type: Ecto.UUID
    belongs_to :plant, Plant, type: Ecto.UUID
    belongs_to :bed, Bed, type: Ecto.UUID
    field :area, :decimal
  end

  @fields [:bed_id, :plant_id, :area]
  def changeset(entry, attrs) do
    entry
    |> Changeset.cast(attrs, @fields)
    |> Changeset.validate_required(@fields)
    |> Changeset.validate_number(:area, greater_than: 0)
  end
end
