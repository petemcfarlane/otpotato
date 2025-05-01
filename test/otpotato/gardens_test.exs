defmodule OTPotato.GardensTest do
  use OTPotato.DataCase

  alias OTPotato.Gardens

  describe "create/1" do
    test "with valid data" do
      assert {:ok, garden} =
               Gardens.create([
                 %{length: 10, width: 10, origin_x: 0, origin_y: 0, soil_type: :chalk},
                 %{length: 4, width: 2, origin_x: 10, origin_y: 0, soil_type: :loam}
               ])

      assert %{beds: beds} = garden
      assert length(beds) == 2
    end

    test "returns error invalid with no beds" do
      assert {:error, error} = Gardens.create([])
      assert error.errors == [beds: {"at least one bed is required", []}]
    end

    test "returns error invalid with overlapping beds" do
      assert {:error, error} =
               Gardens.create([
                 %{length: 2, width: 2, origin_x: 0, origin_y: 0, soil_type: :chalk},
                 %{length: 2, width: 2, origin_x: 1, origin_y: 1, soil_type: :loam}
               ])

      assert error.errors == [beds: {"beds must not overlap", []}]
    end
  end
end
