defmodule GqlOrders.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :description, :text
      add :total, :decimal
      add :balance_due, :decimal

      timestamps()
    end
  end
end
