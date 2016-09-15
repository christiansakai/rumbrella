defmodule Rumbl.ErrorView do
  @shortdoc """
  Render error related pages.
  """

  use Rumbl.Web, :view

  @doc """
  Render 404 Page not found
  """
  def render("404.html", _assigns) do
    "Page not found"
  end

  @doc """
  Render 500 Internal server error
  """
  def render("500.html", _assigns) do
    "Internal server error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
