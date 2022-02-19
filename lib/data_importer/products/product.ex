defmodule DataImporter.Products.Product do
  @moduledoc """
  This module contains schema and changeset
  for product collection.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias DataImporter.Repo

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field :part_number, :string
    field :branch_id, :string
    field :part_price, :float
    field :short_desc, :string
    field :source_file_name, :string

    timestamps()
  end

  @doc """
  A product changeset for uploading products.

  The product identifer (part_number) should always be there,
  as without this It's hard to find product in DB.
  """
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :part_number,
      :branch_id,
      :part_price,
      :short_desc,
      :source_file_name
    ])
    |> validate_required([:part_number])
  end
end
