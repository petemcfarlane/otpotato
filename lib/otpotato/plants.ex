defmodule OTPotato.Plants do
  alias OTPotato.{Plant, Repo}

  @moduledoc """
    Functions for working with plants.
  """

  def plant_ids_by_name do
    Plant
    |> Repo.all()
    |> Enum.into(%{}, &{&1.name, &1.id})
  end
end
