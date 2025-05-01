defmodule OTPotato.Garden do
  use Ecto.Schema

  @moduledoc """
  A garden is a collection of beds.
  """

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :beds]}
  schema "gardens" do
    has_many :beds, OTPotato.Bed
  end
end
