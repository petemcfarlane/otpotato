defmodule OTPotato.PlantingPlans do
  @moduledoc """
  Context for creating and scoring planting plans
  """

  alias OTPotato.{PlantingPlan, PlantingPlanEntry, Repo, Bed}

  alias Ecto.Changeset
  import Ecto.Query

  @doc """
  Create a planting plan
  Requirements:
    - at least one entry in the plan
    - beds referenced in the plan must exist
    - beds must belong to the same garden
    - total of area of plants must not exceed area of bed
  """
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

  @doc """
  Score a planting plan
  Average score of all beds in the plan
  Each bed is scored by:
    - bed is worth 10
    - extra point if planted alongside beneficial companion plants
    - extra point for bed being fully planted
    - deduct one for each plant that is not planted in its preferred soil type
    - any bed with an error automatically returns 0
  """
  def score(id) do
    plan =
      from(p in PlantingPlan,
        preload: [entries: [:bed, :plant]]
      )
      |> Repo.get(id)

    case plan do
      nil ->
        nil

      %{entries: entries} ->
        score =
          entries
          |> Enum.map(&score_entry(&1, entries))
          |> Enum.sum()

        score / length(entries)
    end
  end

  def score_entry(entry, entries) do
    try do
      base_score = 10
      score = base_score

      is_planted_alongside_beneficial_companion? =
        Enum.any?(entries, fn other_entry ->
          other_entry.plant.name in entry.plant.benefits_from
        end)

      score = if is_planted_alongside_beneficial_companion?, do: score + 1, else: score

      is_planted_in_preferred_soil_type? =
        entry.bed.soil_type in entry.plant.soil_types

      score = if is_planted_in_preferred_soil_type?, do: score, else: score - 1

      bed_area = entry.bed.length * entry.bed.width

      is_bed_fully_planted? =
        entries
        |> Enum.filter(fn other_entry -> other_entry.bed_id == entry.bed_id end)
        |> Enum.map(fn other_entry -> other_entry.area end)
        |> Enum.sum() == bed_area

      score = if is_bed_fully_planted?, do: score + 1, else: score

      score
    rescue
      _ -> 0
    catch
      _ -> 0
    end
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

      bed_area = bed.length * bed.width

      bed_area < area_summed_for_this_bed
    end)
  end
end
