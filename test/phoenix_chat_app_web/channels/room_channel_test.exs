defmodule PhoenixChatAppWeb.RoomChannelTest do
  use PhoenixChatAppWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      PhoenixChatAppWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(PhoenixChatAppWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "msg broadcasts to room:lobby", %{socket: socket} do
    push(socket, "msg", %{"name" => "test_name", "message" => "hey all"})
    assert_broadcast "msg", %{"name" => "test_name", "message" => "hey all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end

  test ":after_join sends all existing messages", %{socket: socket} do
    payload = %{name: "Marvin", message: "test"}
    PhoenixChatApp.Message.changeset(%PhoenixChatApp.Message{}, payload) |> PhoenixChatApp.Repo.insert()

    {:ok, _, socket2} = PhoenixChatAppWeb.UserSocket
    |> socket("person_id", %{some: :assign})
    |> subscribe_and_join(PhoenixChatAppWeb.RoomChannel, "room:lobby")

  assert socket2.join_ref != socket.join_ref
  end
end
