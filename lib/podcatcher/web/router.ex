defmodule Podcatcher.Web.Router do
  use Podcatcher.Web, :router

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

  scope "/", Podcatcher.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/discover/", PodcastsController, :index
    get "/latest/", EpisodesController, :index

    get "/browse/", CategoriesController, :index
    get "/browse/:id/:slug", CategoriesController, :category
    get "/browse/:id/", CategoriesController, :category

    get "/episode/:id/:slug", EpisodesController, :episode
    get "/episode/:id/", EpisodesController, :episode

    get "/podcast/:id/:slug", PodcastsController, :podcast
    get "/podcast/:id/", PodcastsController, :podcast

    get "/login/", AuthController, :login
    post "/login/", AuthController, :login

    get "/signup/", AuthController, :signup
    post "/signup/", AuthController, :signup

  end

  # Other scopes may use custom stacks.
  # scope "/api", Podcatcher.Web do
  #   pipe_through :api
  # end
end
