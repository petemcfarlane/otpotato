defmodule OTPotato.BedTest do
  use ExUnit.Case
  doctest OTPotato.Bed
  alias OTPotato.Bed

  describe "changeset/2" do
    test "with valid data" do
      assert %Ecto.Changeset{valid?: true} =
               Bed.changeset(%Bed{}, %{
                 length: 10,
                 width: 10,
                 origin_x: 0,
                 origin_y: 0,
                 soil_type: :chalk
               })
    end

    test "with invalid data" do
      assert %Ecto.Changeset{valid?: false, errors: errors} =
               Bed.changeset(%Bed{}, %{
                 length: -1,
                 width: -12,
                 origin_x: 0,
                 origin_y: 0,
                 soil_type: :chalk
               })

      assert [
               width:
                 {"must be greater than %{number}",
                  [{:validation, :number}, {:kind, :greater_than}, {:number, 0}]},
               length:
                 {"must be greater than %{number}",
                  [{:validation, :number}, {:kind, :greater_than}, {:number, 0}]}
             ] = errors
    end
  end
end
