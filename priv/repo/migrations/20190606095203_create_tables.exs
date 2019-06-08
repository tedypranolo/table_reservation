defmodule Schedule.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :name, :string
      add :restaurant_id, references(:restaurants, on_delete: :nothing)

      timestamps()
    end

    create index(:tables, [:restaurant_id])
  end
end
