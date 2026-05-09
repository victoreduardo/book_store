class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @users       = User.count
    @books       = Book.count
    @orders      = Order.count
    @revenue     = Order.sum(:total)
    @recent_orders = Order.includes(:user).order(created_at: :desc).limit(5)
  end

  def users
    @users = User.all.order(:email)
  end

  def books
    @books = Book.all.order(:title)
  end
end
