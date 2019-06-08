defmodule ScheduleWeb.Router do
  use ScheduleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ScheduleWeb do
    pipe_through :browser

    get "/", SearchController, :index
    get "/search/:fromtime/:totime", SearchController, :search
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScheduleWeb do
  #   pipe_through :api
  # end
end
