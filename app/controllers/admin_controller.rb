# app/controllers/admin_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   Exposição de dados sensíveis: endpoint /admin/users retorna
#   emails e password_digest sem autenticação admin adequada

class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @users       = User.count
    @books       = Book.count
    @orders      = Order.count
    @revenue     = Order.sum(:total)
    @recent_orders = Order.includes(:user).order(created_at: :desc).limit(5)
  end

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ⚠️  VULNERABILIDADE: EXPOSIÇÃO DE DADOS SENSÍVEIS
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # Após elevação de privilégio via SQLi ou mass assignment,
  # o atacante acessa /admin/users e obtém todos os hashes de senha.
  # Endpoint também acessível via SQLi sem ser admin de verdade.
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  def users
    @users = User.all.order(:email)
    # Renderiza email, role, credits e password_digest de todos os usuários
  end

  def books
    @books = Book.all.order(:title)
  end
end
