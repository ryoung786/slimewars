defmodule Slime.Repo do
  use Ecto.Repo,
    otp_app: :slime,
    adapter: Ecto.Adapters.Postgres
end
