defmodule GqlOrders.PaymentsTest do
  use GqlOrders.DataCase

  alias GqlOrders.Payments

  describe "payments" do
    alias GqlOrders.Payments.Payment

    @valid_attrs %{amount: "120.5", applied_at: "2010-04-17T14:00:00Z", note: "some note"}
    @update_attrs %{amount: "456.7", applied_at: "2011-05-18T15:01:01Z", note: "some updated note"}
    @invalid_attrs %{amount: nil, applied_at: nil, note: nil}

    def payment_fixture(attrs \\ %{}) do
      {:ok, payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_payment()

      payment
    end

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      assert {:ok, %Payment{} = payment} = Payments.create_payment(@valid_attrs)
      assert payment.amount == Decimal.new("120.5")
      assert payment.applied_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert payment.note == "some note"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{} = payment} = Payments.update_payment(payment, @update_attrs)
      assert payment.amount == Decimal.new("456.7")
      assert payment.applied_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert payment.note == "some updated note"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end
end
