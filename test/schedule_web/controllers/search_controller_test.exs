defmodule ScheduleWeb.SearchControllerTest do
  use ScheduleWeb.ConnCase
  @date1  "2019-01-01T"
  @date2  "2019-01-02T"
  @date_far  "2019-03-01T"

  describe "search/3" do
    test "Invalid datetime", %{conn: conn} do
      conn =
        conn
        |> get("/search/xxx/yyy")

      assert assert text_response(conn, 400) =~ "fromtime"
    end

    test "Valid datetimes", %{conn: conn} do
      conn =
        conn
        |> get("/search/#{@date1}20:00:00Z/#{@date2}20:00:00Z")

      assert assert text_response(conn, 200) =~ "Ok"
    end

    test "fromtime is after totime", %{conn: conn} do
      conn =
        conn
        |> get("/search/#{@date2}20:00:00Z/#{@date1}20:00:00Z")

      assert assert text_response(conn, 400) =~ "before"
    end

    test "interval too short", %{conn: conn} do
      conn =
        conn
        |> get("/search/#{@date1}20:00:00Z/#{@date1}20:03:00Z")

      assert assert text_response(conn, 400) =~ "least"
    end

    test "interval too long", %{conn: conn} do
      conn =
        conn
        |> get("/search/#{@date1}20:00:00Z/#{@date_far}20:00:00Z")

      assert assert text_response(conn, 400) =~ "most"
    end
  end
end
