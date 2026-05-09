# app/models/book.rb
class Book < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :order_items

  validates :title,  presence: true
  validates :author, presence: true
  validates :price,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def average_rating
    return nil if comments.empty?
    (comments.sum(:rating).to_f / comments.count).round(1)
  end
end
