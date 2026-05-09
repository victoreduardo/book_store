# app/controllers/users_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   Mass Assignment (linha 30): params[:user] sem filtro aceita
#   qualquer atributo, incluindo role e credits

class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # ⚠️  VULNERABILIDADE: MASS ASSIGNMENT
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # params[:user] é passado diretamente para User.new sem filtro.
    # Um atacante pode enviar campos extras via POST:
    #
    #   curl -X POST http://localhost:3000/users \
    #     -d "user[name]=Hacker&user[email]=h@evil.com&user[password]=123
    #         &user[role]=admin&user[credits]=999999"
    #
    # O Rails vai atribuir role="admin" e credits=999999 silenciosamente.
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @user = User.new(params[:user].permit!)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Conta criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
    @orders = @user.orders.order(created_at: :desc)
  end

  def profile
    @user = current_user
  end
end

# ─────────────────────────────────────────────────────────────
# VERSÃO SEGURA (para mostrar no E03):
#
# def create
#   @user = User.new(user_params)  # ← usa strong parameters
#   ...
# end
#
# private
#
# def user_params
#   params.require(:user).permit(:name, :email, :password)
#   # role e credits NÃO estão na lista → ignorados automaticamente
# end
# ─────────────────────────────────────────────────────────────
