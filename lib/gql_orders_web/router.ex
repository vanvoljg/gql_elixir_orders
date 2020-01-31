defmodule GqlOrdersWeb.Router do
  use GqlOrdersWeb, :router

  @schema GqlOrdersWeb.Schema

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: @schema,
      interface: :playground,
      context: %{pubsub: GqlOrdersWeb.Endpoint}

    forward "/", Absinthe.Plug,
      schema: @schema
  end
end
