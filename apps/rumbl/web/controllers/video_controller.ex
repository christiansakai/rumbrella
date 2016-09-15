defmodule Rumbl.VideoController do
  @shortdoc """
  Controller for video related resource.
  """

  use Rumbl.Web, :controller

  alias Rumbl.Video
  alias Rumbl.Category

  # :scrub_params imported by `web/web.ex` by Phoenix.Controller
  # Use this plug before create/3 and update/3 in this module
  plug :scrub_params, "video" when action in [:create, :update]

  # run load_categories/2 (from this module) first
  # before new/3, create/3, edit/3, and update/3 in this module
  plug :load_categories when action in [:new, :create, :edit, :update]

  @doc """
  Get all the videos associated with this user, 
  then call `web/views/video_view.ex` which runs
  the render function.
  """
  def index(conn, _params, user) do
    videos = Repo.all(user_videos(user))
    render(conn, "index.html", videos: videos)
  end

  @doc """
   Call `web/views/video_view.ex` which runs
  the render function.
  """
  def new(conn, _params, user) do
    changeset = 
      user
      |> build_assoc(:videos)
      |> Video.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Associate the newly made video 
  with the logged in user, then
  insert it into the database. Upon successful
  creation, redirect to video index page, upon
  failure, re-render the new form video.
  """
  def create(conn, %{"video" => video_params}, user) do
    changeset = 
      user
      |> build_assoc(:videos)
      |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  @doc """
  Get the video data associated with this user.
  Then call `web/views/video_view.ex` which runs
  the render function.
  """
  def show(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)
    render(conn, "show.html", video: video)
  end

  @doc """
  Get the video data associated with this user.
  Create a changeset, then call `web/views/video_view.ex` 
  which runs the render function and pass the changeset.
  """
  def edit(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  @doc """
  Get the video data associated with this user,
  create a changeset, insert the change into the
  database. Upon succesful insertion, redirect to
  video showing page. Upon error, rerender the edit
  page again.
  """
  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  @doc """
  Get the video associated with this user. 
  Delete the video. Upon successful deletion,
  redirect to video index.
  """
  def delete(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  @doc """
  Modify the standard action callback provided
  by Phoenix.Controller (imported by `web/web.ex`)
  so that all the standard callback (new, create,
  edit, update, delete) all receive 3 arguments, 
  the conn, the conn.params and the assigned logged in user.
  """
  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  defp user_videos(user) do
    assoc(user, :videos)
  end

  defp load_categories(conn, _) do
    query = 
      Category
      |> Category.alphabetical()
      |> Category.names_and_ids()

    categories = Repo.all(query)
    assign(conn, :categories, categories)
  end
end
