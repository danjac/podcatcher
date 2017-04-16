defmodule Podcatcher.Web.Router do
  use Podcatcher.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Podcatcher.Web.Plugs.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Podcatcher.Web.Plugs.Authenticate
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

    get "/bookmarks/", BookmarksController, :index

    get "/subscriptions/", SubscriptionsController, :index

    get "/login/", AuthController, :login
    post "/login/", AuthController, :login

    get "/signup/", AuthController, :signup
    post "/signup/", AuthController, :signup

    get "/logout/", AuthController, :logout

  end

  # Other scopes may use custom stacks.
  scope "/api", Podcatcher.Web do
     pipe_through :api

     post "/bookmarks/:id/", BookmarksController, :add_bookmark
     delete "/bookmarks/:id/", BookmarksController, :delete_bookmark

     post "/subscriptions/:id/", SubscriptionsController, :subscribe
     delete "/subscriptions/:id/", SubscriptionsController, :unsubscribe

  end
end
