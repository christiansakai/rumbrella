defmodule Rumbl.UserController do
  @shortdoc """
  Controller for user related resource.
  """

  use Rumbl.Web, :controller

  alias Rumbl.User
  alias Rumbl.Auth

  # :authenticate_user imported by `web/web.ex`
  # Run :authenticate_user before running index/2 and show/2
  plug :authenticate_user when action in [:index, :show]

  @doc """
  Getting all available users from the database
  and call the module `web/views/user_view.ex` which run
  the render function.
  """
  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  @doc """
  Get changesets from User model and 
  call the module `web/views/user_view.ex` which
  run the render function that passes in the changeset.
  """
  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  @doc """
  Create a changeset from User model by using user
  parameter. Insert that changeset into the database,
  then logging in the user and redirecting it to user index
  path. If the login failed, call the `web/views/user_view.ex` 
  which will run the render function with a passed in changeset.
  """
  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  @doc """
  Getting a particular user according to its id
  and call the module `web/views/user_view.ex`
  which run the render function.
  """
  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end
end
