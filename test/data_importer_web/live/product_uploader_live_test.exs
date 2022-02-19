defmodule DataImporterWeb.ProductUploaderLiveTest do
  use DataImporterWeb.ConnCase

  import Phoenix.LiveViewTest
  import DataImporterWeb.UploadSupport

  describe "Index" do
    test "lists all product", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.product_uploader_path(conn, :index))

      assert html =~ "Uploader here"
      assert html =~ "source_file_name_upload"
    end

    test "upload product file", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.product_uploader_path(conn, :index))
      assert html =~ "Uploader here"

      file =
        [:code.priv_dir(:data_importer), "static", "uploads", "data.csv"]
        |> Path.join()
        |> build_upload("test/csv")

      source_file_name = file_input(index_live, "#product_uploader_form", :source_file_name, [file])

      doc = render_upload(source_file_name, file.name)
      assert doc =~ "List Products"

      doc = doc |> Floki.parse_document!()
      assert doc
        |> Floki.find(~s(tbody[id="product_listing_body"] > tr))
        |> length() == 9
    end
  end
end
