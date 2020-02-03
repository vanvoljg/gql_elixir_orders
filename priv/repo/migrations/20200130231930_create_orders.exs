defmodule GqlOrders.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :description, :text, null: false
      add :total, :decimal, null: false
      add :balance_due, :decimal, null: false

      timestamps()
    end
  end
end
