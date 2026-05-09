# app/controllers/sessions_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   SQLi: interpolação direta de params na query SQL

class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    email    = params[:email].to_s
    password = params[:password].to_s

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # ⚠️  VULNERABILIDADE: SQL INJECTION
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Os parâmetros são interpolados diretamente na query SQL.
    #
    # Payload (fecha aspas + OR; recomendado no SQLite + AR — uma linha SQL):
    #   admin@bookstore.com') OR ('1'='1
    #
    # Payload didático com comentário -- pode causar 500 no SQLite porque o
    # restante da linha (ORDER BY, parênteses) também é comentado.
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    user = User.where(
      "email = '#{email}' AND password_digest = '#{password}'"
    ).first

    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bem-vindo, #{user.name}!"
    else
      flash.now[:alert] = "Email ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Sessão encerrada."
  end
end

# ─────────────────────────────────────────────────────────────
# VERSÃO SEGURA (para mostrar no E03):
#
# def create
#   user = User.find_by(email: params[:email])
#
#   if user && user.authenticate(params[:password])
#     session[:user_id] = user.id
#     redirect_to root_path, notice: "Bem-vindo!"
#   else
#     flash.now[:alert] = "Email ou senha inválidos."
#     render :new, status: :unprocessable_entity
#   end
# end
#
# Requer: has_secure_password no model User (usa bcrypt)
# ─────────────────────────────────────────────────────────────
