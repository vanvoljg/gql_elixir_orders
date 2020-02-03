defmodule GqlOrders.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Changeset, only: [change: 2, fetch_change!: 2, put_change: 3]
  import Ecto.Query, warn: false

  alias GqlOrders.{Order, Payment, Payments, Repo}

  @doc """
  Creates a new payment linked to the provided order id and updates the order with a reduced
  balance due.

  Returns a tuple:
  `{:ok, payment} | {:error, error}`
  """
  def apply_payment(%{order_id: o_id} = args) do
    with %Order{} = order <- Repo.get(Order, o_id),
         {:ok, payment} <- Payments.create_payment(order.balance_due, args) do
      order = update_balance_due(order, payment)
      payment_transaction(order, payment)
    else
      nil -> {:error, "#{o_id} is not a valid order id"}
      {:error, :payment_too_large} = error -> error
    end
  end

  @doc """
  Takes an order changeset and a payment changeset 
  """
  def payment_transaction(order, payment) do
    Repo.transaction(fn ->
      %{updated_at: applied_at} = Repo.update!(order, returning: true)

      payment
      |> put_change(:applied_at, applied_at)
      |> Repo.insert!()
    end)
  end

  @doc """
  Takes an order and a payment 
  """
  def update_balance_due(order, payment) do
    amount = fetch_change!(payment, :amount)
    new_balance_due = Decimal.sub(order.balance_due, amount)
    change(order, balance_due: new_balance_due)
  end

  @doc """
  Takes a set of payment arguments and creates a payment changeset.

  Returns:
  `{:ok, payment_changeset} | {:error, :payment_too_large}`
  """
  def create_payment(balance_due, %{amount: amount} = args) do
    if Decimal.gt?(amount, balance_due) do
      {:error, :payment_too_large}
    else
      {:ok, Payment.changeset(%Payment{}, args)}
    end
  end

  @doc """
  Takes an id and returns a payment or `nil`.
  """
  def get_payment(id), do: Repo.get(Payment, id)

  @doc """
  Takes an order id and returns a list of payments for that order or an empty list.
  """
  def get_payments_by_order(o_id) do
    q =
      from p in Payment,
        where: p.order_id == ^o_id,
        order_by: p.applied_at

    Repo.all(q)
  end
end
