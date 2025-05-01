defmodule OTPotato.PlantingPlansTest do
  use OTPotato.DataCase
  alias OTPotato.{PlantingPlans, PlantingPlan, Repo, Plant}

  setup do
    {:ok, garden = %{beds: [bed]}} =
      OTPotato.Gardens.create([
        %{length: 2.0, width: 2.0, origin_x: 0, origin_y: 0, soil_type: :loam}
      ])

    {:ok, plant} =
      Repo.insert(%Plant{name: "spinach", soil_types: [:loam], benefits_from: []})

    {:ok, garden: garden, bed: bed, plant: plant}
  end

  describe "create/1" do
    test "with valid data", %{bed: %{id: bed_id}, plant: %{id: plant_id}} do
      assert {:ok, planting_plan} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: plant_id, area: 1.0}
               ])

      assert %PlantingPlan{} = planting_plan
    end

    test "beds must belong to the same garden", %{
      bed: %{id: bed_id},
      plant: %{id: plant_id}
    } do
      _garden2 =
        {:ok, %{beds: [bed2]}} =
        OTPotato.Gardens.create([
          %{length: 2, width: 2, origin_x: 0, origin_y: 0, soil_type: :loam}
        ])

      assert {:error, error} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: plant_id, area: 1.0},
                 %{bed_id: bed2.id, plant_id: plant_id, area: 1.0}
               ])

      assert error.errors == [entries: {"beds must belong to the same garden", []}]
    end

    test "total of area of plants must not exceed area of bed", %{
      bed: %{id: bed_id},
      plant: %{id: plant_id}
    } do
      assert {:error, error} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: plant_id, area: 4.1}
               ])

      assert error.errors == [
               entries: {"total of area of plants must not exceed area of bed", []}
             ]
    end

    test "total of area of plants may equal area of bed", %{
      bed: %{id: bed_id},
      plant: %{id: plant_id}
    } do
      assert {:ok, _} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: plant_id, area: 4.0}
               ])
    end
  end
end
