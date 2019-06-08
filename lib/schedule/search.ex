defmodule Schedule.Search do
  import Ecto.Query
  alias Schedule.{Repo, Table, Reservation}

  @min_interval_seconds 60 * 30
  @max_interval_seconds 60 * 60 * 24 * 31
  @invalid_arguments {:error, :invalid_arguments}
  def invalid_arguments do
    @invalid_arguments
  end

  def max_interval_seconds do
    @max_interval_seconds
  end

  def min_interval_seconds do
    @min_interval_seconds
  end

  def get_freetable_query(query_start, query_end) do
    diff = NaiveDateTime.diff(query_end, query_start)
    # [query_start, query_end, diff] |> IO.inspect(label: "Query")

    if diff < @min_interval_seconds or diff > @max_interval_seconds do
      @invalid_arguments
    else
      reserved_query =
        from rs in Reservation,
          where: rs.fromtime < ^query_end and rs.totime > ^query_start,
          distinct: rs.table_id,
          select: rs.table_id

      freetable_query =
        from t in Table,
          join: r in assoc(t, :restaurant),
          left_join: rt in subquery(reserved_query),
          on: t.id == rt.table_id,
          where: is_nil(rt.table_id),
          select: %{id: t.id, table: t.name, restaurant: r.name}

      # Ecto.Adapters.SQL.to_sql(:all, Repo, freetable_query) |> IO.inspect()

      %{free: freetable_query, reserved: reserved_query}
    end
  end
  def get_freetables(query_start, query_end) do
    queries = get_freetable_query(query_start, query_end)
    Repo.all(queries.free)
  end
end
