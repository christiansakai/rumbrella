defmodule Rumbl.WatchController do
  @shortdoc """
  Controller to watch a video.
  """

  use Rumbl.Web, :controller

  alias Rumbl.Video

  @doc """
  Get the video related data, and then call 
  the module `web/views/watch_view.ex` which
  runs the render function.
  """
  def show(conn, %{"id" => id}) do
    video = Repo.get!(Video, id)
    render conn, "show.html", video: video
  end
end
