defmodule DataImporterWeb.UploadSupport do
  @moduledoc """
  Helpers for working with file uploads under test.
  """

  @doc """
  Returns a map of upload attrs for a path and content type.

  ## Examples

      iex(1)> [:code.priv_dir(:data_importer), "static", "uploads", "data.csv"] \
      iex(1)> |> Path.join() \
      iex(1)> |> build_upload("text/csv")
      %{name: "data.csv", type: "text/csv", ...}
  """
  def build_upload(path, content_type \\ "application/octet-stream") do
    upload = %{name: Path.basename(path), type: content_type}

    %{mtime: mtime, size: size} = File.stat!(path)

    last_modified =
      mtime
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix()

    upload
    |> Map.put(:size, size)
    |> Map.put(:last_modified, last_modified)
    |> Map.put(:content, File.read!(path))
  end
end
