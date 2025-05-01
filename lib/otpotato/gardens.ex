defmodule OTPotato.Gardens do
  @moduledoc """
  Context for creating gardens
  """

  alias OTPotato.{Repo, Garden, Bed}
  alias Ecto.Changeset

  @doc """
  Create a garden
  Requirements:
    - at least one bed
    - beds must not overlap
  """
  def create(beds) do
    garden = %Garden{}

    garden
    |> Changeset.cast(%{beds: beds}, [])
    |> Changeset.cast_assoc(:beds, with: &Bed.changeset/2)
    |> Changeset.validate_change(:beds, fn :beds, _beds_changeset ->
      cond do
        beds == [] ->
          [beds: "at least one bed is required"]

        beds_overlap?(beds) ->
          [beds: "beds must not overlap"]

        true ->
          []
      end
    end)
    |> Repo.insert()
  end

  defp beds_overlap?(_beds = []), do: false
  defp beds_overlap?(_beds = [_]), do: false

  defp beds_overlap?([bed | other_beds]) do
    bx = to_float(bed.origin_x)
    by = to_float(bed.origin_y)
    bw = to_float(bed.width)
    bl = to_float(bed.length)

    Enum.any?(other_beds, fn other_bed ->
      ox = to_float(other_bed.origin_x)
      oy = to_float(other_bed.origin_y)
      ow = to_float(other_bed.width)
      ol = to_float(other_bed.length)

      bx < ox + ow and
        bx + bw > ox and
        by < oy + ol and
        by + bl > oy
    end) or beds_overlap?(other_beds)
  end

  defp to_float(val) when is_float(val), do: val
  defp to_float(val) when is_integer(val), do: val * 1.0
  defp to_float(val) when is_binary(val), do: Float.parse(val) |> elem(0)
end
