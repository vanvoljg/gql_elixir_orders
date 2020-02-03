defmodule GqlOrders.Payment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :amount, :decimal
    field :applied_at, :utc_datetime_usec
    field :note, :string

    belongs_to :order, GqlOrders.Order

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  The default changeset, which requires an order id
  """
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :note, :order_id])
    |> validate_required([:amount, :order_id])
  end

  @doc """
  Creates a changeset for use in complete orders.
  """
  def order_complete(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :note])
    |> validate_required([:amount, :note])
  end
end
