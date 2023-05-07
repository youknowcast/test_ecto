defmodule TestEcto.Repo do
  use Ecto.Repo,
    otp_app: :test_ecto,
    adapter: Ecto.Adapters.SQLite3
end
