defmodule OTPotato.Repo do
  use Ecto.Repo,
    otp_app: :otpotato,
    adapter: Ecto.Adapters.Postgres
end
