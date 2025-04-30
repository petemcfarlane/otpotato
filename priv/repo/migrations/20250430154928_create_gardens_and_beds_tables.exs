defmodule OTPotato.Repo.Migrations.CreateGardensTable do
  use Ecto.Migration

  def change do
    create table(:gardens)

    create table(:beds) do
      add :origin_x, :integer
      add :origin_y, :integer
      add :length, :decimal
      add :width, :decimal
      add :soil_type, :string
      add :garden_id, references(:gardens, on_delete: :delete_all)
    end
  end
end
