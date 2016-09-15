defmodule Rumbl.Router do
  @shortdoc """
  This is where all routing happens.
  """

  use Rumbl.Web, :router

  alias Rumbl.Auth
  alias Rumbl.Repo

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth, repo: Repo # Will be passed down to `lib/rumbl/auth.ex`
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Rumbl do
    # Since we define Rumbl in this do scope
    # There is no need to append Rumbl in front of
    # controllers name.
   pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    
    get "/watch/:id", WatchController, :show
  end

  scope "/manage", Rumbl do
    pipe_through [:browser, :authenticate_user] # Imported by `web/web.ex`

    resources "/videos", VideoController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Rumbl do
  #   pipe_through :api
  # end
end
