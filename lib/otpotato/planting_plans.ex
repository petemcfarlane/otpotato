defmodule OTPotato.PlantingPlans do
  alias OTPotato.{PlantingPlan, PlantingPlanEntry, Repo, Bed}

  alias Ecto.Changeset
  import Ecto.Query

  def create(entries) do
    %PlantingPlan{}
    |> Changeset.cast(%{entries: entries}, [])
    |> Changeset.cast_assoc(:entries, with: &PlantingPlanEntry.changeset/2)
    |> Changeset.validate_change(:entries, fn :entries, _entries_changeset ->
      cond do
        entries == [] ->
          [entries: "at least one entry is required"]

        not beds_exist?(entries) ->
          [entries: "bed(s) must exist"]

        not beds_belong_to_same_garden?(entries) ->
          [entries: "beds must belong to the same garden"]

        total_area_of_plants_exceeds_area_of_bed?(entries) ->
          [entries: "total of area of plants must not exceed area of bed"]

        true ->
          []
      end
    end)
    |> Repo.insert()
  end

  defp beds_exist?(entries) do
    unique_bed_ids =
      entries
      |> Enum.map(& &1.bed_id)
      |> Enum.uniq()

    Repo.all(from b in Bed, where: b.id in ^unique_bed_ids, select: b.id)
    |> length() == length(unique_bed_ids)
  end

  defp beds_belong_to_same_garden?(entries) do
    unique_bed_ids =
      entries
      |> Enum.map(& &1.bed_id)
      |> Enum.uniq()

    Repo.all(from b in Bed, where: b.id in ^unique_bed_ids, select: b.garden_id, distinct: true)
    |> length() == 1
  end

  defp total_area_of_plants_exceeds_area_of_bed?(entries) do
    unique_bed_ids =
      entries
      |> Enum.map(& &1.bed_id)
      |> Enum.uniq()

    beds = Repo.all(from b in Bed, where: b.id in ^unique_bed_ids)

    Enum.all?(beds, fn bed ->
      area_summed_for_this_bed =
        entries
        |> Enum.filter(&(&1.bed_id == bed.id))
        |> Enum.map(& &1.area)
        |> Enum.sum()
        |> Decimal.from_float()

      bed_area = Decimal.mult(bed.length, bed.width)

      bed_area |> Decimal.lt?(area_summed_for_this_bed)
    end)
  end
end
