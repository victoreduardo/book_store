class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
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
