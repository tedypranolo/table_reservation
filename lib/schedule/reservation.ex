defmodule Schedule.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservations" do
    field :cust_name, :string
    field :fromtime, :naive_datetime
    field :totime, :naive_datetime
    belongs_to :table, Schedule.Table
    timestamps()
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:fromtime, :totime, :cust_name])
    |> validate_required([:table_id, :fromtime, :totime, :cust_name])
  end

end
