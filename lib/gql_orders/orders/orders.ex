defmodule GqlOrders.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, warn: false

  alias GqlOrders.{Order, Payment, Repo}

  @doc """
  Takes a set of order arguments and returns a tuple:
  `{order, payment}`
  """
  def build_complete_order(args) do
    order = %{
      total: args.total,
      description: args.description,
      balance_due: 0
    }

    payment = %{
      amount: order.total,
      note: args[:note] || "Full total payment"
    }

    {order, payment}
  end

  @doc """
  Creates an order.

  Returns a tuple:
  `{:ok, order} | {:error, changeset}`
  """
  def create_order(args) do
    %Order{}
    |> Order.changeset(args)
    |> Repo.insert(returning: true)
  end

  @doc """
  Takes a list of errors from a changeset and returns a list with errors parsed to strings.
  """
  def errors_to_list(errors) do
    Enum.map(errors, &parse_error/1)
  end

  @doc """
  Gets an order by its id. Returns an order or `nil`.
  """
  def get_order(id), do: Repo.get(Order, id)

  @doc """
  Gets a list of all orders. Returns a list of orders or an empty list (if no orders found).
  """
  def get_all_orders do
    q =
      from o in Order,
        order_by: o.inserted_at

    Repo.all(q)
  end

  @doc """
  Creates an order and payment in a single operation. The payment amount will be automatically
  set to the order total.

  Returns a tuple:
  `{:ok, order} | {:error, [errors]}`
  """
  def order_complete(args) do
    {order, payment} = build_complete_order(args)

    order = Order.changeset(%Order{}, order)
    payment = Payment.order_complete(%Payment{}, payment)
    order_complete_transaction(order, payment)
  end

  @doc """
  Takes an order changeset and a payment changeset and transactionally inserts both into the
  database.

  Returns a tuple:
  `{:ok, order} | {:error, [errors]}`
  """
  def order_complete_transaction(order, payment) do
    if order.valid? === true do
      Repo.transaction(fn ->
        order = Repo.insert!(order, returning: true)

        payment
        |> change(order_id: order.id, applied_at: order.updated_at)
        |> Repo.insert!(returning: true)

        order
      end)
    else
      {:error, errors_to_list(order.errors)}
    end
  end

  # Helpers -------------------------------------------------------------------

  defp parse_error({field, {msg, args}}) when is_list(args) do
    "#{field} #{msg}, arguments #{List.to_string(args)}"
  end

  defp parse_error({field, {msg, _}}) do
    "#{field} #{msg}"
  end
end
