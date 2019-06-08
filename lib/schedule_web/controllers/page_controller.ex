defmodule ScheduleWeb.PageController do
  use ScheduleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
