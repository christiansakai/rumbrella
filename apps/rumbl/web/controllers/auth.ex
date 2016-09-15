defmodule Rumbl.Auth do
  @shortdoc """
  Authentication module for this web app.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Rumbl.User
  alias Rumbl.Router.Helpers
  alias Comeonin.Bcrypt

  @doc """
  This is a @callback that a plug module
  must implement. It receives opts passed from `web/router.ex`
  line 10 by plug. Whatever it returns will be
  passed down to call/2.
  """
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  @doc """
  This is a @callback that a plug module
  must implement. It receives conn struct
  as the first argument and whatever returned
  by the init/1 as the second argument.
  It must return back the modified conn struct.
  """
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    # For testing purposes
    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  @doc """
  Log in the user by putting current_user, 
  user_token in the assign and user_id in
  the session. Also renew the session each time.
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @doc """
  login the user by checking the username and
  encrypted password against the database.
  """
  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, username: username)

    cond do
      user && Bcrypt.checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        Bcrypt.dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  @doc """
  Logout the user by dropping the current session.
  """
  def logout(conn) do
    configure_session(conn, drop: true)
  end
 
  @doc """
  Check whether a user is authenticated or not by
  checking the assigns. If a user is not in the assign
  it will redirect to `index.html` and halt the connection.
  """
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
