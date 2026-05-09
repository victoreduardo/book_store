# app/controllers/books_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   SQLi no search: interpolação direta do parâmetro q em find_by_sql

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
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # ⚠️  VULNERABILIDADE: SQL INJECTION via campo de busca
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Interpolação direta + find_by_sql: o UNION fica no nível do SELECT
      # (compatível com SQLite), e não dentro de um LIKE (que quebraria).
      #
      # Busca “normal”: use título ou autor exatos (ex.: "Ruby por exemplo").
      #
      # Payload UNION (9 colunas = schema de books):
      #   q=' UNION SELECT id,email,password_digest,name,1.0,role,credits,datetime('now'),datetime('now') FROM users --
      #
      # Retorna linhas de usuários como se fossem livros (título=email, etc.).
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      @books = Book.find_by_sql(
        "SELECT books.* FROM books WHERE title = '#{query}' OR author = '#{query}'"
      )
    end

    render :index
  end

  private

  # VERSÃO SEGURA:
  # @books = Book.where("title LIKE ? OR author LIKE ?", "%#{query}%", "%#{query}%")
end
