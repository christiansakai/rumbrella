defmodule Rumbl.UserView do
  @shortdoc """
  Render static pages or JSON
  related to User module.
  """

  use Rumbl.Web, :view

  alias Rumbl.User

  @doc """
  Get a first name from user struct.
  """
  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

  @doc """
  Send user.json to the front end.
  """
  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end
end
