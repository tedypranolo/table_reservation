defmodule Schedule.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :fromtime, :naive_datetime
      add :totime, :naive_datetime
      add :cust_name, :string
      add :table_id, references(:tables, on_delete: :nothing)

      timestamps()
    end

    create index(:reservations, [:table_id])
  end
end
