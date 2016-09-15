defmodule Rumbl.Category do
  @shortdoc """
  Model related to category resource.
  """

  use Rumbl.Web, :model

  schema "categories" do
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  @doc """
  Build a query that queries alphabetically.
  """
  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  @doc """
  Build a query that only selects name and id.
  """
  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end
