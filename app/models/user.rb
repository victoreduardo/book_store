# app/models/user.rb
#
# ⚠️  MODELO INTENCIONALMENTE VULNERÁVEL — USO EXCLUSIVO EM LABORATÓRIO
#
# Vulnerabilidades presentes:
#   1. has_secure_password está desabilitado — password armazenado em campo separado
#      para permitir a demo de SQL injection com comparação direta
#   2. Sem validação de formato de email
#   3. Sem limite de tentativas de login
#   4. Atributo :role e :credits acessíveis (mass assignment demo)

class User < ApplicationRecord
  # ⚠️  VULN: password armazenado em texto puro em `password_digest`
  # para facilitar a demo de SQLi com comparação direta na query
  # Em produção real: use has_secure_password com bcrypt
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
    # Armazena a senha em texto puro para que a query SQL de comparação
    # funcione corretamente durante a demo de SQL injection:
    #
    #   WHERE email = '[input]' AND password_digest = '[input]'
    #
    # Com bcrypt/SHA1, o hash hex dentro da string SQL causa
    # erros de parse no SQLite ("unrecognized token").
    self.password_digest = password if password.present?
  end
end
