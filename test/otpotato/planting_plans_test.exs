defmodule OTPotato.PlantingPlansTest do
  use OTPotato.DataCase
  alias OTPotato.{PlantingPlans, PlantingPlan, PlantingPlanEntry, Repo, Plant, Gardens, Bed}

  setup do
    {:ok, garden = %{beds: [bed]}} =
      Gardens.create([
        %{length: 2.0, width: 2.0, origin_x: 0, origin_y: 0, soil_type: :loam}
      ])

    {:ok, spinach} =
      Repo.insert(%Plant{name: "spinach", soil_types: [:loam], benefits_from: []})

    {:ok, potato} =
      Repo.insert(%Plant{
        name: "potato",
        soil_types: [:chalk],
        benefits_from: ["spinach", "tomato"]
      })

    {:ok, tomato} =
      Repo.insert(%Plant{name: "tomato", soil_types: [:sandy], benefits_from: ["spinach"]})

    {:ok, carrot} =
      Repo.insert(%Plant{name: "carrot", soil_types: [:sandy], benefits_from: []})

    {:ok,
     garden: garden, bed: bed, spinach: spinach, potato: potato, tomato: tomato, carrot: carrot}
  end

  describe "create/1" do
    test "with valid data", %{bed: %{id: bed_id}, spinach: %{id: spinach_id}} do
      assert {:ok, planting_plan} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: spinach_id, area: 1.0}
               ])

      assert %PlantingPlan{} = planting_plan
    end

    test "beds must belong to the same garden", %{
      bed: %{id: bed_id},
      spinach: %{id: spinach_id}
    } do
      _garden2 =
        {:ok, %{beds: [bed2]}} =
        Gardens.create([
          %{length: 2, width: 2, origin_x: 0, origin_y: 0, soil_type: :loam}
        ])

      assert {:error, error} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: spinach_id, area: 1.0},
                 %{bed_id: bed2.id, plant_id: spinach_id, area: 1.0}
               ])

      assert error.errors == [entries: {"beds must belong to the same garden", []}]
    end

    test "total of area of plants must not exceed area of bed", %{
      bed: %{id: bed_id},
      spinach: %{id: spinach_id}
    } do
      assert {:error, error} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: spinach_id, area: 4.1}
               ])

      assert error.errors == [
               entries: {"total of area of plants must not exceed area of bed", []}
             ]
    end

    test "total of area of plants may equal area of bed", %{
      bed: %{id: bed_id},
      spinach: %{id: spinach_id}
    } do
      assert {:ok, _} =
               PlantingPlans.create([
                 %{bed_id: bed_id, plant_id: spinach_id, area: 4.0}
               ])
    end
  end

  describe "score/1" do
    test "returns average score of all beds in plan", %{
      spinach: spinach,
      potato: potato,
      tomato: tomato,
      carrot: carrot
    } do
      {:ok, _garden = %{beds: [bed1, bed2, bed3]}} =
        Gardens.create([
          %{length: 2, width: 2, origin_x: 0, origin_y: 0, soil_type: :loam},
          %{length: 10, width: 10, origin_x: 2, origin_y: 2, soil_type: :chalk},
          %{length: 3, width: 4, origin_x: 12, origin_y: 12, soil_type: :sandy}
        ])

      {:ok, planting_plan} =
        PlantingPlans.create([
          # score 10
          %{bed_id: bed1.id, plant_id: spinach.id, area: 1.0},
          # score 10
          %{bed_id: bed1.id, plant_id: potato.id, area: 2.0},
          # score 11
          %{bed_id: bed2.id, plant_id: potato.id, area: 2.0},
          # score 11
          %{bed_id: bed3.id, plant_id: tomato.id, area: 3.0},
          # score 9
          %{bed_id: bed2.id, plant_id: carrot.id, area: 1.0}
        ])

      assert 10.2 = PlantingPlans.score(planting_plan.id)
    end

    test "returns nil if planting plan does not exist" do
      assert nil == PlantingPlans.score(Ecto.UUID.generate())
    end
  end

  describe "score_entry/2" do
    test "base score is 10" do
      assert 10 ==
               PlantingPlans.score_entry(
                 %PlantingPlanEntry{
                   area: 1.0,
                   plant: %Plant{soil_types: [:chalk]},
                   bed: %Bed{soil_type: :chalk, length: 2.0, width: 2.0}
                 },
                 []
               )
    end

    test "add one for each plant that is planted alongside a beneficial companion" do
      assert 11 ==
               PlantingPlans.score_entry(
                 %PlantingPlanEntry{
                   area: 1.0,
                   bed: %Bed{soil_type: :clay, width: 2.0, length: 2.0},
                   plant: %Plant{name: "potato", benefits_from: ["spinach"], soil_types: [:clay]}
                 },
                 [
                   %PlantingPlanEntry{
                     area: 1.0,
                     bed: %Bed{soil_type: :clay, width: 2.0, length: 2.0},
                     plant: %Plant{
                       name: "potato",
                       benefits_from: ["spinach"],
                       soil_types: [:clay]
                     }
                   },
                   %PlantingPlanEntry{
                     area: 1.0,
                     bed: %Bed{soil_type: :clay, width: 2.0, length: 2.0},
                     plant: %Plant{
                       name: "spinach",
                       benefits_from: [],
                       soil_types: [:clay]
                     }
                   }
                 ]
               )
    end

    test "deduct one for each plant that is not planted in its preferred soil type" do
      assert 9 ==
               PlantingPlans.score_entry(
                 %PlantingPlanEntry{
                   plant: %{soil_types: [:chalk]},
                   bed: %{soil_type: :loam, length: 1.0, width: 1.0}
                 },
                 []
               )
    end

    test "add one if the bed is fully planted" do
      bed_id = Ecto.UUID.generate()

      assert 11 ==
               PlantingPlans.score_entry(
                 %PlantingPlanEntry{
                   area: 1.0,
                   plant: %{
                     name: "potato",
                     soil_types: [:chalk],
                     benefits_from: []
                   },
                   bed: %{id: bed_id, width: 2.0, length: 3.0, soil_type: :chalk}
                 },
                 [
                   %PlantingPlanEntry{
                     area: 1.0,
                     plant: %{
                       name: "potato",
                       soil_types: [:chalk],
                       benefits_from: []
                     },
                     bed: %{id: bed_id, width: 2.0, length: 3.0, soil_type: :chalk}
                   },
                   %PlantingPlanEntry{
                     area: 5.0,
                     plant: %{name: "spinach", soil_types: [:chalk], benefits_from: []},
                     bed: %{id: bed_id, width: 2.0, length: 3.0, soil_type: :chalk}
                   }
                 ]
               )
    end

    test "any bed with an error automatically returns 0" do
      assert 0 ==
               PlantingPlans.score_entry(
                 %PlantingPlanEntry{bed: %Bed{soil_type: :loam}, plant: %{soil_types: [:chalk]}},
                 []
               )
    end
  end
end
