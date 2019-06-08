# Schedule

To simplify cases, all dates are NaiveDateTime. No timezone checks are included.

[search_test.exs](/test/schedule/search_test.exs) tests [search.ex](/lib/schedule/search.ex)

- should find correct tables when the queried time is between, before and after reservations
- should correctly exclude reserved table when the queried time overlaps reservations
- invalid arguments such as when the interval queried is too short or too long, reversed

[search_controller_test.exs](/test/schedule_web/controllers/search_controller_test.exs) tests [search.ex](/lib/schedule_web/controllers/search_controller.ex)

- Tests for valid date format (iso8601 format is expected)
- Tests for invalid intervals
- Tests for warning when the query contains suspicious info, such as non-zero timezone (we are assuming everything should be queried as UTC)

**To run test**

​	env MIX_ENV=test mix test

**To run web app**

​	env MIX_ENV=dev mix ecto.setup

​	env MIX_ENV=dev mix phx.server

Some samples

- valid (returns json) http://localhost:4000/search/2019-01-01T01:00:00Z/2019-01-01T02:00:00Z
- invalid http://localhost:4000/search/xxx/yyy