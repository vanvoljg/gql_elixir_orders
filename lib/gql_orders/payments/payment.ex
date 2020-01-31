defmodule GqlOrders.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :amount, :decimal
    field :applied_at, :utc_datetime
    field :note, :string

    belongs_to :order, GqlOrders.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :applied_at, :note])
    |> validate_required([:amount, :applied_at, :note])
  end
end
