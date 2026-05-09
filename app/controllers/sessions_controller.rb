class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    email    = params[:email].to_s
    password = params[:password].to_s

    user = User.where(
      "email = '#{email}' AND password_digest = '#{password}'"
    ).first

    if user
      session[:user_id] = user.id
      destination = params[:return_to].presence || root_path
      redirect_opts = { notice: "Bem-vindo, #{user.name}!" }
      redirect_opts[:allow_other_host] = true if destination.to_s.match?(%r{\Ahttps?://}i)
      redirect_to destination, **redirect_opts
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
