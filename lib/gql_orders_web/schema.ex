defmodule GqlOrdersWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  import Ecto.Query

  alias GqlOrders.{Order, Payment, Repo}

  import_types(Absinthe.Type.Custom)

  # Types ---------------------------------------------------------------------

  @desc "An order"
  object :order do
    field(:id, non_null(:id))
    field(:description, non_null(:string))
    field(:total, non_null(:decimal))
    field(:balance_due, non_null(:decimal))

    field :payments_applied, non_null(list_of(:payment)) do
      resolve(&get_payments_by_order/3)
    end
  end

  @desc "A payment"
  object :payment do
    field(:id, non_null(:id))
    field(:amount, non_null(:decimal))
    field(:applied_at, non_null(:datetime))
    field(:order_id, non_null(:id))
  end

  # Queries -------------------------------------------------------------------

  query do
    @desc "Get a list of all orders"
    field :all_orders, non_null(list_of(:order)) do
      resolve(&get_all_orders/3)
    end

    @desc "Get a single order by ID"
    field :order, non_null(:order) do
      arg(:id, non_null(:id))
      resolve(&get_order/3)
    end

    @desc "Get a single payment by ID"
    field :payment, non_null(:payment) do
      arg(:id, non_null(:id))
      resolve(&get_payment/3)
    end

    @desc "Get a list of payments for an order, by order ID"
    field :payments_by_order, non_null(list_of(:payment)) do
      arg(:order_id, non_null(:id))
      resolve(&get_payments_by_order/3)
    end
  end

  # Mutations -----------------------------------------------------------------

  mutation do
    @desc "Create an order"
    field :create_order, non_null(:order) do
      arg(:total, non_null(:decimal))
      arg(:description, non_null(:string))
      resolve(&create_order/3)
    end

    @desc "Apply a payment to an order"
    field :apply_payment, non_null(:payment) do
      arg(:amount, non_null(:decimal))
      arg(:order_id, non_null(:id))
      arg(:note, :string)
      resolve(&ni/3)
    end

    @desc "Create an order and apply a payment in one transaction"
    field :create_order_payment, non_null(:order) do
      arg(:total, non_null(:decimal))
      arg(:description, non_null(:string))
      arg(:amount, non_null(:decimal))
      arg(:note, :string)
      resolve(&ni/3)
    end
  end

  # Resolvers -----------------------------------------------------------------

  def ni(parent, args, _resolution) do
    IO.puts("ni/3")
    IO.puts("Parent: #{inspect(parent)}")
    IO.puts("Args: #{inspect(args)}")
    {:error, "Not implemented"}
  end

  def create_order(_parent, args, _resolution) do
    case repo_create_order(args) do
      {:error, _changeset} ->
        {:error, "There was an error creating the order"}

      {:ok, order} ->
        {:ok, order}
    end
  end

  def get_all_orders(_parent, _args, _resolution) do
    {:ok, repo_get_all_orders()}
  end

  def get_order(_parent, %{id: id}, _resolution) do
    case repo_get_order(id) do
      nil -> {:error, "#{id} is not a valid order id"}
      order -> {:ok, order}
    end
  end

  def get_payment(_parent, %{id: id}, _resolution) do
    case repo_get_payment(id) do
      nil -> {:error, "#{id} is not a valid payment id"}
      payment -> {:ok, payment}
    end
  end

  def get_payments_by_order(%Order{id: order_id}, _args, _resolution) do
    {:ok, repo_get_payments_by_order(order_id)}
  end

  def get_payments_by_order(_parent, %{order_id: order_id}, _resolution) do
    {:ok, repo_get_payments_by_order(order_id)}
  end

  # Repo access methods -------------------------------------------------------

  def repo_create_order(args) do
    %Order{}
    |> Order.changeset(args)
    |> Repo.insert(returning: true)
  end

  def repo_get_payment(id) do
    Repo.get(Payment, id)
  end

  def repo_get_payments_by_order(id) do
    q = from(p in Payment, where: p.order_id == ^id)
    Repo.all(q)
  end

  def repo_get_order(id) do
    q =
      from(o in Order,
        where: o.id == ^id
      )

    Repo.one(q)
  end

  def repo_get_all_orders() do
    case Repo.all(Order) do
      nil -> []
      orders -> orders
    end
  end
end
