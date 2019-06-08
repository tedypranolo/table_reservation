defmodule Schedule.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset
  schema "restaurants" do
    field :address, :string
    field :name, :string
    has_many :tables, Schedule.Table
    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :address])
    |> validate_required([:name, :address])
  end

  def insert(attrs \\ %{}) do
   %Schedule.Restaurant{}
    |> Schedule.Restaurant.changeset(attrs)
    |> Repo.insert()
  end
end
