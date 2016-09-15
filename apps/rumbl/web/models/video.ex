defmodule Rumbl.Video do
  @shortdoc """
  Model related to video resource.
  """

  use Rumbl.Web, :model

  # Use @primary_key module attribute to let
  # Ecto knows that this is the primary_key used.
  # It expects a three element tuple
  # {field_name, type, options}
  # see `lib/rumbl/permalink.ex`
  @primary_key {:id, Rumbl.Permalink, autogenerate: true}

  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :slug, :string

    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category

    has_many :annotations, Rumbl.Annotation

    timestamps()
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  This also slugify the title and make sure that
  the category that relates to category_id is available
  in the database.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :title, :description, :user_id, :category_id])
    |> validate_required([:url, :title, :description, :user_id])
    |> slugify_title()
    |> assoc_constraint(:category)
  end
  
  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  @spec slugify(binary) :: binary
  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end

defimpl Phoenix.Param, for: Rumbl.Video do
  @shortdoc """
  Make sure that Phoenix.Param protocol honors
  the slug. This will be used watch path (video/index.html.eex)
  """

  @doc """
  Change a video struct to string param.
  """
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
