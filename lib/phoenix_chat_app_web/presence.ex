defmodule PhoenixChatAppWeb.Presence do
  use Phoenix.Presence,
    otp_app: :phoenix_chat_app,
    pubsub_server: PhoenixChatApp.PubSub
end
