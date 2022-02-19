defmodule DataImporterWeb.ProductUploaderLive do
  use DataImporterWeb, :live_view

  import Ecto.Query, warn: false

  alias DataImporter.{
    FileUploader,
    Products
  }

  @schema %{source_file_name: :string}
  @default_data %FileUploader{}
  @storage_path "priv/static/uploads"
  @chunk_size 100

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign_changeset()
      |> assign(:uploaded_files, [])
      |> assign(:products, nil)
      |> allow_upload(:source_file_name,
        accept: ~w(.csv),
        max_entries: 1,
        progress: &handle_progress/3
      )
    }
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {
      :noreply,
      socket
      |> Map.put(:action, :validate)
    }
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    {
      :noreply,
      socket
      |> put_flash(:info, "Product updated successfully")
    }
  end

  defp assign_changeset(socket) do
    socket
    |> assign(:changeset, changeset())
  end

  # HACK: It's schemaless changeset for file uploads
  # Since I don't have any default schema for file uploading.
  defp changeset() do
    changeset =
      {@default_data, @schema}
      |> Ecto.Changeset.cast(%{}, Map.keys(@schema))

    changeset
  end

  defp handle_progress(:source_file_name, entry, socket) do
    if entry.done? do
      path =
        consume_uploaded_entry(
          socket,
          entry,
          &upload_static_file(&1, socket)
        )

      execute_uploaded_file(path)

      {
        :noreply,
        socket
        |> assign(:products, fetch_records!())
        |> put_flash(:info, "file #{entry.client_name} uploaded")
      }
    else
      {:noreply, socket}
    end
  end

  defp upload_static_file(%{path: path}, socket) do
    # Plug in your production image file persistence implementation here!
    dest = Path.join(@storage_path, Path.basename(path))
    File.cp!(path, dest)
    Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
  end

  # Read file via stream, and create chunks.
  defp execute_uploaded_file(file_name) do
    dest = Path.join(@storage_path, Path.basename(file_name))

    File.stream!(dest)
    |> Stream.with_index()
    |> Stream.chunk_every(@chunk_size)
    |> Stream.each(&write_into_db!(&1, file_name))
    |> Stream.run()

    clear_older_records(file_name)
  end

  # Optimize records and write them into DB.
  defp write_into_db!(prodcuts, file_name) do
    prodcuts =
      Enum.map(prodcuts, fn {product, _line} ->
        product
        |> String.replace(~r/[\x{200B}\x{200C}\x{200D}\x{FEFF}\\\r\n\\"]/u, "")
        |> String.split("|", trim: true)
        |> map_schema!(file_name)
      end)

    Products.create_all(prodcuts)
  end

  # Fetch records from DB to list them.
  defp fetch_records!() do
    Products.list_products!()
  end

  defp map_schema!([part_number, branch_id, part_price, short_desc], file_name) do
    %{
      "part_number" => part_number,
      "branch_id" => branch_id,
      "part_price" => part_price,
      "short_desc" => short_desc,
      "source_file_name" => file_name
    }
  end

  defp map_schema!(_, _), do: nil

  # This function is to achieve the bonus feature from README.MD
  # Bonus Feature: Products that are not in the CSV get deleted (optional, can be enabled)
  defp clear_older_records(file_name) do
    Products.delete_all!(file_name)
  end
end
