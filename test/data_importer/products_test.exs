defmodule DataImporter.ProductsTest do

  use DataImporter.DataCase
  use ExUnit.Case, async: true
  alias DataImporter.Products


  @create_attrs %{part_number: "a part number", branch_id: "a branch id", part_price: 42.0, short_desc: "some description", source_file_name: "a_file_name.csv"}
  @many_valid_attr [
    %{
      "branch_id" => "TUC",
      "part_number" => "0121G00047P",
      "part_price" => "42.5",
      "short_desc" => "GALV x FAB x .026 x 29.88 x 17.56",
      "source_file_name" => "/uploads/live_view_upload-1643197404-661958505230593-3"
    },
    %{
      "branch_id" => "TUC",
      "part_number" => "0121F00548",
      "part_price" => "3.14",
      "short_desc" => "GALV x FAB x 0121F00548 x 16093 x .026 x 29.88 x 17.56",
      "source_file_name" => "/uploads/live_view_upload-1643197404-661958505230593-3"
    },
  ]

  @many_not_valid_attr [
    %{
      "branch_id" => nil,
      "part_number" => nil,
      "part_price" => nil,
      "short_desc" => nil,
      "source_file_name" => "/uploads/live_view_upload-1643197404-661958505230593-3"
    },
    %{
      "branch_id" => "TUC",
      "part_number" => "0121F00548",
      "part_price" => "3.14",
      "short_desc" => "GALV x FAB x 0121F00548 x 16093 x .026 x 29.88 x 17.56",
      "source_file_name" => "/uploads/live_view_upload-1643197404-661958505230593-3"
    },
  ]

  defp fixture(:product) do
    {:ok, product} = Products.create(@create_attrs)
    product
  end

  defp create_product() do
    product = fixture(:product)
    %{product: product}
  end

  describe "product actions" do
    test "list_products/0 returns all products" do
      %{product: product} = create_product()

      assert Products.list_products!() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      %{product: product} = create_product()

      assert Products.get_product!(product.id).id == product.id
    end

    test "delete_all/1 deletes all products with file_name" do
      %{product: product} = create_product()

      assert {1, nil} = Products.delete_all!("some_file_name")
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "create_all/1 returns tuple" do
      assert {2, nil} = Products.create_all(@many_valid_attr)
      assert {1, nil} = Products.create_all(@many_not_valid_attr)

      assert length(Products.list_products!()) == 3
    end
  end
end
