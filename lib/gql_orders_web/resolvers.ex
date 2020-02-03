defmodule GqlOrdersWeb.Resolvers do
  @moduledoc false

  alias GqlOrders.{Order, Orders, Payments}
  
  # Resolvers -----------------------------------------------------------------

  @doc """
  Applies a payment to an order.
  """
  def apply_payment(_parent, args, _resolution) do
    Payments.apply_payment(args)
  end

  @doc """
  Creates a new order
  """
  def create_order(_parent, args, _resolution) do
    Orders.create_order(args)
  end

  @doc """
  Gets a list of all orders
  """
  def get_all_orders(_parent, _args, _resolution) do
    {:ok, Orders.get_all_orders()}
  end

  @doc """
  Gets a single order by ID
  """
  def get_order(_parent, %{id: id}, _resolution) do
    case Orders.get_order(id) do
      nil -> {:error, "#{id} is not a valid order id"}
      order -> {:ok, order}
    end
  end

  @doc """
  Get a single payment by ID
  """
  def get_payment(_parent, %{id: id}, _resolution) do
    case Payments.get_payment(id) do
      nil -> {:error, "#{id} is not a valid payment id"}
      payment -> {:ok, payment}
    end
  end

  @doc """
  Get a list of payments by order ID.
  """
  def get_payments_by_order(%Order{id: o_id}, _args, _resolution) do
    {:ok, Payments.get_payments_by_order(o_id)}
  end

  def get_payments_by_order(_parent, %{order_id: o_id}, _resolution) do
    {:ok, Payments.get_payments_by_order(o_id)}
  end

  @doc """
  Create a completed/fully paid order
  """
  def order_complete(_parent, args, _resolution) do
    Orders.order_complete(args)
  end
end
