# app/controllers/orders_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   IDOR (Insecure Direct Object Reference): qualquer usuário logado
#   pode acessar o pedido de qualquer outro usuário pelo ID

class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # ⚠️  VULNERABILIDADE: IDOR
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Order.find(id) busca qualquer pedido no banco — sem verificar
    # se o pedido pertence ao current_user.
    #
    # Alice logada pode acessar http://localhost:3000/orders/1
    # e ver o pedido do admin (que inclui endereço e últimos 4 do cartão).
    #
    # Basta iterar os IDs: /orders/1, /orders/2, /orders/3...
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @order = Order.find(params[:id])
    @items = @order.order_items.includes(:book)
  end

  def create
    @order = current_user.orders.build(
      total:      params[:total],
      address:    params[:address],
      card_last4: params[:card_number].to_s.last(4),
      status:     "pending"
    )

    if @order.save
      redirect_to @order, notice: "Pedido realizado com sucesso!"
    else
      redirect_to books_path, alert: "Erro ao criar pedido."
    end
  end

  # ─────────────────────────────────────────────────────────────
  # VERSÃO SEGURA (para mostrar no E03):
  #
  # def show
  #   # Busca APENAS pedidos do usuário atual → IDOR impossível
  #   @order = current_user.orders.find(params[:id])
  #   @items = @order.order_items.includes(:book)
  # rescue ActiveRecord::RecordNotFound
  #   redirect_to orders_path, alert: "Pedido não encontrado."
  # end
  # ─────────────────────────────────────────────────────────────
end
