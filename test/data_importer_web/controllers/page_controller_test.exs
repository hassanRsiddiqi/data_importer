defmodule DataImporterWeb.PageControllerTest do
  use DataImporterWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Uploader here"
  end
end
