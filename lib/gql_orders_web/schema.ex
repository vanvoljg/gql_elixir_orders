defmodule GqlOrdersWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  import Ecto.{Changeset, Query}

  alias Decimal
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
    field(:note, :string)
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
      resolve(&apply_payment/3)
    end

    @desc "Create an order and apply a payment in one transaction"
    field :order_complete, non_null(:order) do
      arg(:total, non_null(:decimal))
      arg(:description, non_null(:string))
      arg(:note, :string)
      resolve(&order_complete/3)
    end
  end

  # Resolvers -----------------------------------------------------------------

  def order_complete(_parent, args, _resolution) do
    repo_order_complete(args)
  end

  def apply_payment(_parent, args, _resolution) do
    repo_apply_payment(args)
  end

  def create_order(_parent, args, _resolution) do
    repo_create_order(args)
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

  def get_payments_by_order(%Order{id: o_id}, _args, _resolution) do
    {:ok, repo_get_payments_by_order(o_id)}
  end

  def get_payments_by_order(_parent, %{order_id: o_id}, _resolution) do
    {:ok, repo_get_payments_by_order(o_id)}
  end

  # Repo access methods -------------------------------------------------------

  def repo_order_complete(args) do
    {order, payment} = build_complete_order(args)

    order = Order.changeset(%Order{}, order)
    payment = Payment.order_complete(%Payment{}, payment)
    order_complete_transaction(order, payment)
  end

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
      {:error, priv_errors_to_list(order.errors)}
    end
  end

  def priv_errors_to_list(errors) do
    for {field, {msg, _args}} <- errors, do: "#{field} #{msg}"
  end

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

  def repo_apply_payment(%{order_id: o_id} = args) do
    with %Order{} = order <- Repo.get(Order, o_id),
         %Ecto.Changeset{} = payment <- repo_create_payment(order.balance_due, args) do
      order = priv_update_balance_due(order, payment)
      priv_payment_transaction(order, payment)
    else
      nil -> {:error, "#{o_id} is not a valid order id"}
      :payment_too_large = error -> {:error, error}
    end
  end

  def priv_payment_transaction(order, payment) do
    Repo.transaction(fn ->
      %{updated_at: applied_at} = Repo.update!(order, returning: true)

      payment
      |> put_change(:applied_at, applied_at)
      |> Repo.insert!(returning: true)
    end)
  end

  def priv_update_balance_due(order, payment) do
    amount = fetch_change!(payment, :amount)
    new_balance_due = Decimal.sub(order.balance_due, amount)
    change(order, balance_due: new_balance_due)
  end

  def repo_create_order(args) do
    %Order{}
    |> Order.changeset(args)
    |> Repo.insert(returning: true)
  end

  def repo_create_payment(balance_due, %{amount: amount} = args) do
    if Decimal.gt?(amount, balance_due) do
      :payment_too_large
    else
      Payment.changeset(%Payment{}, args)
    end
  end

  def repo_get_all_orders do
    q =
      from o in Order,
        order_by: o.inserted_at

    Repo.all(q)
  end

  def repo_get_order(id), do: Repo.get(Order, id)

  def repo_get_payment(id), do: Repo.get(Payment, id)

  def repo_get_payments_by_order(o_id) do
    q =
      from p in Payment,
        where: p.order_id == ^o_id,
        order_by: p.applied_at

    Repo.all(q)
  end
end
