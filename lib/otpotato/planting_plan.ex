defmodule OTPotato.PlantingPlan do
  use Ecto.Schema

  alias OTPotato.PlantingPlanEntry

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :entries]}
  schema "planting_plans" do
    has_many :entries, PlantingPlanEntry
  end
end
