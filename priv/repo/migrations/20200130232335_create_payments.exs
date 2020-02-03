defmodule GqlOrders.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal, null: false
      add :applied_at, :utc_datetime_usec
      add :note, :text, default: ""
      add :order_id, references(:orders, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:payments, [:order_id])
    create index(:payments, [:applied_at])
  end
end
