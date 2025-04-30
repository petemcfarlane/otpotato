defmodule OTPotato.Repo.Migrations.CreatePlantsTable do
  use Ecto.Migration

  def change do
    create table(:plants) do
      add :name, :string, null: false
      add :soil_types, {:array, :string}, null: false
      add :benefits_from, {:array, :string}, null: false
    end

    # enforcing a unique property here makes it harder to accidentally create duplicate plants
    create unique_index(:plants, [:name])
  end
end
