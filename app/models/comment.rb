# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :book
  belongs_to :user

  # ⚠️  VULN: sem sanitização do body — XSS demo
  # A view renderiza com raw(), permitindo injeção de scripts
  validates :body, presence: true
  validates :rating, inclusion: { in: 1..5 }
end
