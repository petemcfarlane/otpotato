defmodule OTPotatoWeb.PlantingPlanController do
  use OTPotatoWeb, :controller

  alias OTPotato.{PlantingPlans, Plants}

  def create(conn, %{"_csv" => plan}) do
    with plants_by_name <- Plants.plant_ids_by_name(),
         {:ok, plan} <- transform_input_data(plan, plants_by_name),
         {:ok, planting_plan} <- PlantingPlans.create(plan) do
      entries =
        planting_plan.entries
        |> Enum.map(fn entry ->
          %{
            "bed-id" => entry.bed_id,
            "plant" =>
              plants_by_name
              |> Enum.find_value(fn {name, id} -> if id == entry.plant_id, do: name end),
            "area" => entry.area
          }
        end)

      conn
      |> put_status(:created)
      |> json(%{planting_plan: %{id: planting_plan.id, entries: entries}})
    else
      {:error, error} when is_binary(error) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: error})

      {:error, %Ecto.Changeset{errors: errors}} ->
        errors =
          errors
          |> Enum.map(fn {key, {message, _}} -> "#{key}: #{message}" end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: errors})

      _error ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Internal server error"})
    end
  end

  def score(conn, %{"id" => id}) do
    score = PlantingPlans.score(id)

    conn
    |> put_status(:ok)
    |> json(%{score: score})
  end

  defp transform_input_data(plan, plants_by_name) do
    plan
    |> Enum.reduce(
      {:ok, []},
      fn
        %{"bed-id" => bed_id, "plant" => plant, "area" => area}, {:ok, acc} ->
          case Map.get(plants_by_name, plant) do
            nil ->
              {:error, "Plant not found: #{plant}"}

            plant_id ->
              {:ok,
               acc ++ [%{bed_id: bed_id, plant_id: plant_id, area: Float.parse(area) |> elem(0)}]}
          end

        _, {:error, error} ->
          {:error, error}

        _, _ ->
          {:error, "Invalid plan data, expected {bed-id, plant, area}"}
      end
    )
  end
end
