defmodule GqlOrders.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal
      add :applied_at, :utc_datetime
      add :note, :text
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:payments, [:order_id])
    create index(:payments, [:applied_at])
  end
end
