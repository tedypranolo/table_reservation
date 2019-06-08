defmodule Schedule.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :name, :string
      add :address, :string

      timestamps()
    end

  end
end
