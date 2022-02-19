defmodule DataImporter.Repo.Migrations.CreateProductsTable do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :part_number, :string
      add :branch_id, :string
      add :part_price, :float
      add :short_desc, :string
      add :source_file_name, :string
      add :updated_at, :utc_datetime_usec
      add :inserted_at, :utc_datetime_usec, default: fragment("CURRENT_TIMESTAMP")
    end

    create index(:products, [:part_number]) # we can create unique_index, If identifier is unique.
    create index(:products, [:source_file_name])
  end
end
