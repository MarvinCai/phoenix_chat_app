defmodule PhoenixChatAppWeb.RoomChannel do
  alias PhoenixChatApp.Repo
  alias PhoenixChatApp.Message
  alias PhoenixChatAppWeb.Presence
  use Ecto.Schema
  use PhoenixChatAppWeb, :channel

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("msg", payload, socket) do
   {:ok, msg} =  %Message{}
    |> Message.changeset(payload)
    |> Repo.insert

    socket
    |> assign(:user_name, msg.name)
    |> track_presence
    |> broadcast("msg", Map.put_new(payload, :id, msg.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Message.get_last_20_messages()
      |> Enum.each(&(push(socket, "msg", &1)))
    push(socket, "presence_state", Presence.list("room:lobby"))
    {:noreply, socket}
  end

  defp track_presence(%{assigns: %{user_name: user_name}} = socket) do
    Presence.track(socket, user_name, %{online_at: inspect(System.system_time(:second))})
    socket
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
