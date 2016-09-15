defmodule Rumbl.SessionController do
  @shortdoc """
  Controller for session related resource.
  """

  use Rumbl.Web, :controller

  alias Rumbl.Auth
  alias Rumbl.Repo

  @doc """
  Call the module `web/views/session_view.ex` which
  run the render function.
  """
  def new(conn, _) do
    render conn, "new.html"
  end

  @doc """
  Call the Auth module to login by using username and password
  into the repo. Upon successful login, redirect to `index.html`. 
  Upon failure rendering, redirect back to the login form.`
  """
  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  @doc """
  Logout the user by calling Auth module, and
  redirect back to use `index.html`.
  """
  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end
