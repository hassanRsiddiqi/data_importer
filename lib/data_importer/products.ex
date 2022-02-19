defmodule DataImporter.Products do
  @moduledoc """
  The Products context.This modules contains helper
  functions to communicate with products table in DB.
  """

  import Ecto.Query, warn: false
  alias DataImporter.Repo
  alias DataImporter.Products.Product

  @doc """
  Creates a product.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Product{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Create multiple product.

  ## Examples

      iex> create_all(%{field: value})
      {:ok, %Product{}}

      iex> create_all(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_all(list \\ []) do
    items =
      list
      |> Stream.map(&Product.changeset(%Product{}, &1))
      |> Stream.filter(fn %Ecto.Changeset{} = item_changeset ->
        item_changeset.valid?
      end)
      |> Stream.map(&process_values(&1))
      |> Enum.to_list()

    Repo.insert_all(Product, items)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp process_values(valid_item_changeset) do
    # turns products changesets into a list of %Product{}
    item = %Product{} = Ecto.Changeset.apply_changes(valid_item_changeset)

    # turns %Product{} into a map with only non-nil item values (no association or __meta__ structs)
    item
    |> Map.from_struct()
    |> Enum.reject(&reject_falsy_values(&1))
  end

  defp reject_falsy_values({_key, nil}), do: true
  defp reject_falsy_values({_key, %DateTime{}}), do: false
  # rejects __meta__: #Ecto.Schema.Metadata<:built, "Product">
  defp reject_falsy_values({_key, %_other_struct{}}), do: true
  defp reject_falsy_values({_key, _}), do: false

  @doc """
  Delete multiple products.

  ## Examples
      iex> delete_all(%{field: value})
      {:ok, %Product{}}

      iex> delete_all(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def delete_all!(file_name) do
    from(v in Product, where: v.source_file_name != ^file_name)
    |> Repo.delete_all(timeout: 200_000)
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_products!() do
    # Hack: We can also use any pagination library for pagination.
    Product
    |> Repo.all()
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)
  """
  def get_product!(id), do: Repo.get!(Product, id)
end
