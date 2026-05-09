class User < ApplicationRecord
  attr_accessor :password

  before_save :set_password_digest

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  has_many :comments, dependent: :destroy
  has_many :orders,   dependent: :destroy

  def admin?
    role == "admin"
  end

  def to_s
    "#{name} <#{email}>"
  end

  private

  def set_password_digest
    self.password_digest = password if password.present?
  end
end
