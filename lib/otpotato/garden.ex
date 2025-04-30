defmodule OTPotato.Garden do
  use Ecto.Schema

  @moduledoc """
  A garden is a collection of beds.
  """

  schema "gardens" do
    embeds_many :beds, OTPotato.Bed
  end
end
