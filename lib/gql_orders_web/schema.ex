defmodule GqlOrdersWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias GqlOrdersWeb.Resolvers

  import_types(Absinthe.Type.Custom)
  import_types(GqlOrdersWeb.Schema.Types)

  # Queries -------------------------------------------------------------------

  query do
    @desc "Get a list of all orders"
    field :all_orders, non_null(list_of(:order)) do
      resolve(&Resolvers.get_all_orders/3)
    end

    @desc "Get a single order by ID"
    field :order, non_null(:order) do
      arg(:id, non_null(:id))
      resolve(&Resolvers.get_order/3)
    end

    @desc "Get a single payment by ID"
    field :payment, non_null(:payment) do
      arg(:id, non_null(:id))
      resolve(&Resolvers.get_payment/3)
    end

    @desc "Get a list of payments for an order, by order ID"
    field :payments_by_order, non_null(list_of(:payment)) do
      arg(:order_id, non_null(:id))
      resolve(&Resolvers.get_payments_by_order/3)
    end
  end

  # Mutations -----------------------------------------------------------------

  mutation do
    @desc "Create an order"
    field :create_order, non_null(:order) do
      arg(:total, non_null(:decimal))
      arg(:description, non_null(:string))
      resolve(&Resolvers.create_order/3)
    end

    @desc "Apply a payment to an order"
    field :apply_payment, non_null(:payment) do
      arg(:amount, non_null(:decimal))
      arg(:order_id, non_null(:id))
      arg(:note, :string)
      resolve(&Resolvers.apply_payment/3)
    end

    @desc "Create an order and apply a payment in one transaction"
    field :order_complete, non_null(:order) do
      arg(:total, non_null(:decimal))
      arg(:description, non_null(:string))
      arg(:note, :string)
      resolve(&Resolvers.order_complete/3)
    end
  end
end
