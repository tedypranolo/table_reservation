defmodule Schedule.Table do
  use Ecto.Schema
  import Ecto.Changeset
  alias Schedule.Repo
  schema "tables" do
    field(:name, :string)
    belongs_to :restaurant, Schedule.Restaurant
    has_many :reservations, Schedule.Reservation
    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def insert(attrs \\ %{}) do
    %Schedule.Table{}
    |> Schedule.Table.changeset(attrs)
    |> Repo.insert()
  end
end
