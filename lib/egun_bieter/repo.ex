defmodule EgunBieter.Repo do
  use Ecto.Repo,
    otp_app: :egun_bieter,
    adapter: Ecto.Adapters.SQLite3
end
