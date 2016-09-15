defmodule Rumbl.Permalink do
  @moduledoc """
  A module that implements Ecto.Type behavior.
  See `web/models/video.ex`. This implementation
  is related to slugify_title/1 in that module.
  
  So basically this module becomes
  the primary key (id) of Rumbl.Video.
  """

  @behaviour Ecto.Type

  @doc """
  This module type is an id type.
  See `web/models/video.ex`.
  """
  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer)do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
