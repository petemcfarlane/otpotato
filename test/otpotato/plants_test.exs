defmodule OTPotato.PlantsTest do
  use OTPotato.DataCase
  alias OTPotato.{Plants, Plant, Repo}

  setup do
    {:ok, spinach} =
      Repo.insert(%Plant{name: "spinach", soil_types: [:loam], benefits_from: []})

    {:ok, potato} =
      Repo.insert(%Plant{name: "potato", soil_types: [:chalk], benefits_from: []})

    {:ok, tomato} =
      Repo.insert(%Plant{name: "tomato", soil_types: [:sandy], benefits_from: []})

    {:ok, plants: %{spinach: spinach, potato: potato, tomato: tomato}}
  end

  describe "plant_ids_by_name/0" do
    test "returns a map of plant names to ids", %{plants: plants} do
      assert %{
               "spinach" => plants.spinach.id,
               "potato" => plants.potato.id,
               "tomato" => plants.tomato.id
             } == Plants.plant_ids_by_name()
    end
  end
end
