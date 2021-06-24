defmodule Rinari.Repo do
  use Ecto.Repo,
    otp_app: :rinari,
    adapter: Ecto.Adapters.Postgres
end
