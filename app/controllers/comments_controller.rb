class CommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])

    @comment = @book.comments.build(
      body:   params[:comment][:body],
      rating: params[:comment][:rating],
      user:   current_user
    )

    if @comment.save
      redirect_to @book, notice: "Comentário publicado!"
    else
      @comments = @book.comments.includes(:user).order(created_at: :desc)
      render "books/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @book    = @comment.book
    @comment.destroy
    redirect_to @book, notice: "Comentário removido."
  end
end
