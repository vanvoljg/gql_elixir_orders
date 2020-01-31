defmodule GqlOrders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :balance_due, :decimal
    field :description, :string
    field :total, :decimal

    has_many :payments_applied, GqlOrders.Payment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:description, :total, :balance_due])
    |> validate_required([:description, :total, :balance_due])
  end
end
