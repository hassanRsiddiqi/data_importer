defmodule DataImporter.Repo do
  use Ecto.Repo,
    otp_app: :data_importer,
    adapter: Ecto.Adapters.Postgres
end
