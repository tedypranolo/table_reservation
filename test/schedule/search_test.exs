defmodule Schedule.Search.CreateTest do
  @moduledoc false
  use Schedule.DataCase
  alias Schedule.{Repo, Table, Restaurant, Reservation, Search}

  @restaurant %Restaurant{
    name: "Bikkuri Donki",
    address: "Tokyo"
  }
  @restaurant2 %Restaurant{
    name: "At the edge of the Universe",
    address: "Space"
  }
  @table %Table{
    name: "Table with reservations"
  }
  @table2 %Table{
    name: "Free Table"
  }
  @table3 %Table{
    name: "Free table at different restaurant"
  }

  @hour 60 * 60
  @minute 60

  @sample_start_time ~N[2019-01-01 00:00:00]
  @doc "offset for @sample_start_time "
  @free_hours Enum.to_list(8..9)
  # keep last number of free_hours, because the end is exclusive (i.e there should a reservation starting at 4)
  @reserved_hours Enum.to_list(6..12) -- Enum.drop(@free_hours, -1)
  @invalid_arguments Search.invalid_arguments()
  @min_interval_minutes div(Search.min_interval_seconds(), 60)
  @max_interval_minutes div(Search.max_interval_seconds(), 60)
  def create_sample_time(hour_offset, minute_offset \\ 0, start_time \\ @sample_start_time) do
    NaiveDateTime.add(start_time, hour_offset * @hour + minute_offset * @minute)
  end

  setup do
    sample_start_times = Enum.map(@reserved_hours, fn x -> create_sample_time(x) end)

    resto = @restaurant |> Repo.insert!()
    table = Ecto.build_assoc(resto, :tables, @table) |> Repo.insert!()
    Ecto.build_assoc(resto, :tables, @table2) |> Repo.insert!()
    resto2 = @restaurant2 |> Repo.insert!()
    Ecto.build_assoc(resto2, :tables, @table3) |> Repo.insert!()

    create_reservation = fn st ->
      rs = %Reservation{fromtime: st, totime: create_sample_time(1, 0, st), table: table}
      Repo.insert!(rs)
    end

    Enum.map(sample_start_times, fn st ->
      st
      |> create_reservation.()
      |> (fn rs ->
            %{
              table_: rs.table.id,
              table_name: rs.table.name,
              fromtime: rs.fromtime,
              totime: rs.totime
            }
          end).()
    end)

    {:ok,
     table_with_reservation: table,
     free_hour_start: List.first(@free_hours),
     free_hour_end: List.last(@free_hours),
     reserve_hour_start: List.first(@reserved_hours),
     reserve_hour_end: List.last(@reserved_hours) + 1}
  end

  defp table_with_reservation_isfree?(
         context,
         start_hour,
         start_minute,
         end_hour,
         end_minute,
         label \\ nil
       ) do
    query_start = create_sample_time(start_hour, start_minute)
    query_end = create_sample_time(end_hour, end_minute)

    if label do
      {query_start, query_end} |> IO.inspect(label: label)
    end

    queries = Search.get_freetable_query(query_start, query_end)
    # Repo.all(from r in Reservation)
    # |> IO.inspect(label: "All Reservations")

    # Repo.all(queries.reserved)
    # |> IO.inspect(label: "Reservations within query")
    case queries do
      @invalid_arguments ->
        queries

      _ ->
        Repo.all(queries.free)
        # |> IO.inspect(label: "Free Tables")
        |> Enum.any?(fn x -> x.id == context.table_with_reservation.id end)
    end
  end

  test "table should be free between reserved times", context do
    assert table_with_reservation_isfree?(
             context,
             context.free_hour_start,
             0,
             context.free_hour_end,
             0
           )
  end

  test "table should be free when query is after all reservations", context do
    assert table_with_reservation_isfree?(
             context,
             context.reserve_hour_end,
             30,
             context.reserve_hour_end,
             60
           )
  end

  test "table should be free when query is before all reservations", context do
    assert table_with_reservation_isfree?(
             context,
             context.reserve_hour_end,
             30,
             context.reserve_hour_end,
             60
           )
  end

  test "table should not be free when query start within a reserved time", context do
    refute table_with_reservation_isfree?(
             context,
             context.free_hour_start,
             -30,
             context.free_hour_end,
             0
           )
  end

  test "table should not be free when query end within a reserved time", context do
    refute table_with_reservation_isfree?(
             context,
             context.free_hour_start,
             0,
             context.free_hour_end,
             30
           )
  end

  test "table should not be free when all reservations is within the query", context do
    refute table_with_reservation_isfree?(
             context,
             context.reserve_hour_start,
             -30,
             context.reserve_hour_end,
             30
           )
  end

  test "table should not be free when query starts between free time", context do
    refute table_with_reservation_isfree?(
             context,
             context.free_hour_start,
             30,
             context.reserve_hour_end,
             30
           )
  end

  test "table should not be free when query ends between free time", context do
    refute table_with_reservation_isfree?(
             context,
             context.reserve_hour_start,
             -30,
             context.free_hour_start,
             30
           )
  end

  test "query should fail if end is before start", context do
    @invalid_arguments =
      table_with_reservation_isfree?(
        context,
        context.free_hour_end,
        0,
        context.free_hour_start,
        0
      )
  end

  test "query should fail if interval is too small", context do
    @invalid_arguments =
      table_with_reservation_isfree?(
        context,
        context.free_hour_start,
        0,
        context.free_hour_start,
        @min_interval_minutes - 1,
        "too small"
      )
  end

  test "query should fail if interval is too large", context do
    @invalid_arguments =
      table_with_reservation_isfree?(
        context,
        context.free_hour_start,
        0,
        context.free_hour_start,
        @max_interval_minutes + 1,
        "too large"
      )
  end
end
