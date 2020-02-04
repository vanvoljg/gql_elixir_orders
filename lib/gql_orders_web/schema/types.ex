defmodule GqlOrdersWeb.Schema.Types do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias GqlOrdersWeb.Resolvers

  @desc "An order"
  object :order do
    field(:id, non_null(:id))
    field(:description, non_null(:string))
    field(:total, non_null(:decimal))
    field(:balance_due, non_null(:decimal))

    field :payments_applied, non_null(list_of(:payment)) do
      resolve(&Resolvers.get_payments_by_order/3)
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

end
