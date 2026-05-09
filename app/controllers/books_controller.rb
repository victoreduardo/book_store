class BooksController < ApplicationController
  skip_before_action :require_login, only: [:index, :show, :search]

  def index
    @books = Book.all.order(:title)
    @categories = Book.distinct.pluck(:category).compact.sort
  end

  def show
    @book    = Book.find(params[:id])
    @comments = @book.comments.includes(:user).order(created_at: :desc)
    @comment  = Comment.new
  end

  def search
    query = params[:q].to_s.strip

    if query.blank?
      @books = Book.all
    else
      @books = Book.find_by_sql(
        "SELECT books.* FROM books WHERE title = '#{query}' OR author = '#{query}'"
      )
    end

    render :index
  end
end
