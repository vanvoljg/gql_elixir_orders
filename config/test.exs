use Mix.Config

# Configure your database
config :gql_orders, GqlOrders.Repo,
  username: "postgres",
  password: "postgres",
  database: "gql_orders_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gql_orders, GqlOrdersWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
