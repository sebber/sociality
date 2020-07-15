defmodule Sociality.Repo do
  use Ecto.Repo,
    otp_app: :sociality,
    adapter: Ecto.Adapters.Postgres
end
