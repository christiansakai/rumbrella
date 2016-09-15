defmodule Rumbl.PageController do
  @shortdoc """
  Controller for main page.
  """

  use Rumbl.Web, :controller

  @doc """
  Calling the function render on `web/views/page_view.ex`
  """
  def index(conn, _params) do
    render conn, "index.html"
  end
end
