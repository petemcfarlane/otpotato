defmodule OTPotato.PlantingPlan do
  use Ecto.Schema

  schema "planting_plans" do
    belongs_to :garden, OTPotato.Garden
    belongs_to :bed, OTPotato.Bed
    belongs_to :plant, OTPotato.Plant
    field :area, :decimal
  end
end
