defmodule OTPotatoWeb.GardenController do
  use OTPotatoWeb, :controller

  alias OTPotato.Gardens

  def create(conn, %{"_csv" => beds}) do
    with {:ok, beds} <- transform_beds_input_data(beds),
         {:ok, garden} <- Gardens.create(beds) do
      conn
      |> put_status(:created)
      |> json(%{garden: garden})
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

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error:
        "Invalid request, please provide a garden in CSV format, e.g. \"x,y,l,w,soil_type\". Don't forget to set the ContentType header to \"text/csv\"."
    })
  end

  defp transform_beds_input_data(beds) do
    beds
    |> Enum.reduce({:ok, []}, fn
      %{"x" => x, "y" => y, "l" => l, "w" => w, "soil_type" => soil_type}, {:ok, acc} ->
        {:ok,
         acc ++
           [
             %{
               origin_x: x,
               origin_y: y,
               length: l,
               width: w,
               soil_type: soil_type
             }
           ]}

      _, _ ->
        {:error, "Invalid bed data, expected {x, y, l, w, soil_type}"}
    end)
  end
end
