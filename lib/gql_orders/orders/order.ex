defmodule GqlOrders.Order do
  @moduledoc false

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
    |> cast(attrs, [:description, :total])
    |> update_balance_due(attrs)
    |> validate_required([:description, :total, :balance_due])
  end

  defp update_balance_due(changeset, attrs)
       when is_map_key(attrs, :balance_due) do
    cast(changeset, attrs, [:balance_due])
  end

  defp update_balance_due(changeset, _attrs) do
    total = fetch_change!(changeset, :total)
    put_change(changeset, :balance_due, total)
  end
end
