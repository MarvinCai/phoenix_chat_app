defmodule PhoenixChatApp.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias PhoenixChatApp.Repo

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end

  def get_last_20_messages() do
    from(PhoenixChatApp.Message)
    |> limit(20)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end
end
