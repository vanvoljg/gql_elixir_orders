defmodule GqlOrders.Repo do
  use Ecto.Repo,
    otp_app: :gql_orders,
    adapter: Ecto.Adapters.Postgres
end
