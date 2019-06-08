defmodule Mix.Tasks.Schedule.Env_Seed do
  use Mix.Task
  alias Schedule.{Repo, Restaurant, Table, Reservation}

  def run(_) do
    Mix.Task.run("app.start", [])
    seed(Mix.env())
  end

  def seed(:dev) do
    r1 = Repo.insert!(%Restaurant{id: 1, name: "At the end of the universe"})
    r2 = Repo.insert!(%Restaurant{id: 2, name: "Jiro's"})
    r3 = Repo.insert!(%Restaurant{id: 3, name: "Taco Bell"})

    table = Repo.insert!(%Table{name: "Table A", restaurant: r1})
    Repo.insert!(%Table{name: "Table B", restaurant: r1})
    Repo.insert!(%Table{name: "Table C", restaurant: r1})

    Repo.insert!(%Table{name: "Table D", restaurant: r2})
    Repo.insert!(%Table{name: "Table E", restaurant: r2})
    Repo.insert!(%Table{name: "Table F", restaurant: r2})

    Repo.insert!(%Table{name: "Table G", restaurant: r3})
    Repo.insert!(%Table{name: "Table H", restaurant: r3})
    Repo.insert!(%Table{name: "Table I", restaurant: r3})
    Repo.insert!(%Reservation{cust_name: "Tim", table: table, fromtime: ~N[2019-01-01 08:00:00], totime: ~N[2019-01-01 09:00:00]})
    Repo.insert!(%Reservation{cust_name: "Tom", table: table, fromtime: ~N[2019-01-01 10:00:00], totime: ~N[2019-01-01 11:00:00]})
  end

  def seed(:prod) do
    # Proceed with caution for production
  end
end
