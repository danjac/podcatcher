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

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  scope "/", Podcatcher.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/latest/", EpisodesController, :index

    get "/discover/", PodcastsController, :index
    get "/discover/episodes/", EpisodesController, :search

    get "/browse/", CategoriesController, :index
    get "/browse/:id/:slug", CategoriesController, :category
    get "/browse/:id/", CategoriesController, :category

    get "/episode/:id/:slug", EpisodesController, :episode
    get "/episode/:id/", EpisodesController, :episode

    get "/podcast/:id/:slug", PodcastsController, :podcast
    get "/podcast/:id/", PodcastsController, :podcast

    get "/bookmarks/", BookmarksController, :index

    get "/feed/", SubscriptionsController, :index

    # authentication routes

    get "/login/", AuthController, :login
    post "/login/", AuthController, :handle_login

    get "/signup/", AuthController, :signup
    post "/signup/", AuthController, :handle_signup

    get "/recoverpass/", AuthController, :recover_password
    post "/recoverpass/", AuthController, :handle_recover_password

    get "/recoverpassdone/", AuthController, :recover_password_done

    get "/changepass/", AuthController, :change_password
    put "/changepass/", AuthController, :update_password

    get "/changemail/", AuthController, :change_email
    put "/changemail/", AuthController, :update_email

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
