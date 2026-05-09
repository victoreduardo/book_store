# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items

  STATUSES = %w[pending shipped delivered cancelled].freeze

  validates :status, inclusion: { in: STATUSES }

  # ⚠️  VULN: sem verificação de ownership em nível de model
  # IDOR demo: qualquer usuário logado pode acessar qualquer order pelo ID
end
