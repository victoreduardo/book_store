class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items

  STATUSES = %w[pending shipped delivered cancelled].freeze

  validates :status, inclusion: { in: STATUSES }
end
