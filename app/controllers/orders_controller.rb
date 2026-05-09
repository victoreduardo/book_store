class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
    @items = @order.order_items.includes(:book)
  end

  def create
    @order = current_user.orders.build(
      total:      params[:total],
      address:    params[:address],
      card_last4: params[:card_number].to_s.last(4),
      status:     params[:status].presence || "pending"
    )

    if @order.save
      redirect_to @order, notice: "Pedido realizado com sucesso!"
    else
      redirect_to books_path, alert: "Erro ao criar pedido."
    end
  end
end
