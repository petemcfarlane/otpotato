defmodule OTPotato.Garden do
  use Ecto.Schema

  @moduledoc """
  A garden is a collection of beds.
  """

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "gardens" do
    has_many :beds, OTPotato.Bed
  end
end
