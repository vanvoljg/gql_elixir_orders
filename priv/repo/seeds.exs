# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GqlOrders.Repo.insert!(%GqlOrders.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias GqlOrders.{Order, Payment, Repo}

Repo.insert!(
  %Order{
    description: "Order 1 description",
    total: 100.54,
    balance_due: 100.54
  }
)

Repo.insert!(
  %Order{
    description: "Order 2, one payment applied",
    total: 233.00,
    balance_due: 133.00,
    payments_applied: [
      %Payment{
        amount: 50.00,
        applied_at: DateTime.utc_now(),
        note: "Applied"
      },
      %Payment{
        amount: 50.00,
        applied_at: DateTime.utc_now(),
        note: ""
      }
    ]
  }
)

Repo.insert!(
  %Order{
    description: "Order 3",
    total: 50.00,
    balance_due: 0.00,
    payments_applied: [
      %Payment{
        amount: 50.00,
        applied_at: DateTime.utc_now(),
        note: "Order complete!"
      }
    ]
  }
)
