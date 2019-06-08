
defmodule ScheduleWeb.SearchController do
  use ScheduleWeb, :controller
  alias Schedule.Search
  def index(conn, _params) do
    render(conn, "index.html")
  end

  # 30 minutes
  @min_interval_seconds Search.min_interval_seconds
  # 31 days
  @max_interval_seconds Search.max_interval_seconds
  def search(conn, %{"fromtime" => fromtimestring, "totime" => totimestring}) do
    fromres = DateTime.from_iso8601(fromtimestring)
    tores = DateTime.from_iso8601(totimestring)

    case {fromres, tores} do
      {{:ok, fromtime, 0}, {:ok, totime, 0}} ->
        # validate interval
        case DateTime.diff(totime, fromtime) do
          n when n <= 0 ->
            conn
            |> put_status(400)
            |> text("Error, fromtime has to be before totime")

          n when n <= @min_interval_seconds ->
            conn
            |> put_status(400)
            |> text(
              "Error, fromtime has to be at least #{@min_interval_seconds} seconds before totime"
            )

          n when n > @max_interval_seconds ->
            conn
            |> put_status(400)
            |> text(
              "Suspicious range, totime has to be at most #{@max_interval_seconds} seconds after fromtime"
            )

          _ ->
            conn
            |> json(Search.get_freetables(fromtime, totime))
        end

      _ ->
        conn
        |> put_status(400)
        |> text("Error, fromtime and/or totime parameter is invalid!")
    end
  end


end
