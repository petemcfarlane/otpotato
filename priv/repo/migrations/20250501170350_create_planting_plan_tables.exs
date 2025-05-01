defmodule OTPotato.Repo.Migrations.CreatePlantingPlanTables do
  use Ecto.Migration

  def change do
    create table(:planting_plans)

    create table(:planting_plan_entries) do
      add :planting_plan_id, references(:planting_plans, type: :uuid)
      add :plant_id, references(:plants, type: :uuid)
      add :bed_id, references(:beds, type: :uuid)
      add :area, :float
    end

    create index(:planting_plan_entries, [:planting_plan_id])
  end
end
