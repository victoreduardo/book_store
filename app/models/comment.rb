class Comment < ApplicationRecord
  belongs_to :book
  belongs_to :user

  validates :body, presence: true
  validates :rating, inclusion: { in: 1..5 }
end
