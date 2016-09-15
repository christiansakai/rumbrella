defmodule Rumbl.AnnotationView do
  @shortdoc """
  Render static pages or JSON 
  related to Annotation module.
  """

  use Rumbl.Web, :view

  @doc """
  Sends annotation.json to the front end.
  """
  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: render_one(annotation.user, Rumbl.UserView, "user.json")
    }
  end
end
