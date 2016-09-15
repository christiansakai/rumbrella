defmodule Rumbl.WatchView do
  @shortdoc """
  Render static pages or JSON
  related to Watch module.
  """

  use Rumbl.Web, :view

  @doc """
  A helper function to extract
  a youtube video id from a 
  video struct.
  """
  def player_id(video) do
    ~r{^.*(?:youtu\.be/|\w+/|v=)(?<id>[^#&?]*)}
    |> Regex.named_captures(video.url)
    |> get_in(["id"])
  end
end
