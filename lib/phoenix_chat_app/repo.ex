defmodule PhoenixChatApp.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_chat_app,
    adapter: Ecto.Adapters.Postgres
end
