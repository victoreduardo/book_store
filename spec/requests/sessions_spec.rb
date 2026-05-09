require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:admin) do
    User.create!(
      name: "Admin", email: "admin@bookstore.com",
      password: "password123", role: "admin"
    )
  end

  describe "POST /login" do
    context "credenciais válidas" do
      it "autentica o usuário e cria sessão" do
        post login_path, params: { email: "admin@bookstore.com", password: "password123" }
        expect(response).to redirect_to(root_path)
      end
    end

    context "credenciais inválidas" do
      it "não autentica com senha errada" do
        post login_path, params: { email: "admin@bookstore.com", password: "senhaerrada" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "SQL injection attempts" do
      it "rejeita payload com comentário SQL (-- )" do
        post login_path, params: {
          email: "admin@bookstore.com' -- ",
          password: "qualquercoisa"
        }
        expect(response).not_to redirect_to(root_path)
        expect(session[:user_id]).to be_nil
      end

      it "rejeita payload OR 1=1" do
        post login_path, params: {
          email: "' OR '1'='1",
          password: "' OR '1'='1"
        }
        expect(response).not_to redirect_to(root_path)
        expect(session[:user_id]).to be_nil
      end

      it "rejeita payload com UNION SELECT" do
        post login_path, params: {
          email: "' UNION SELECT 1,2,3,4,5 -- ",
          password: "x"
        }
        expect(response).not_to redirect_to(root_path)
      end
    end
  end
end

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    context "mass assignment" do
      it "ignora o parâmetro role=admin" do
        post "/users", params: {
          user: {
            name: "Hacker",
            email: "hacker@evil.com",
            password: "senha123",
            role: "admin"
          }
        }
        user = User.find_by(email: "hacker@evil.com")
        expect(user).to be_present
        expect(user.role).to eq("user")
      end

      it "ignora o parâmetro credits com valor alto" do
        post "/users", params: {
          user: {
            name: "Hacker",
            email: "rico@evil.com",
            password: "senha123",
            credits: 999_999
          }
        }
        user = User.find_by(email: "rico@evil.com")
        expect(user.credits).to eq(0)
      end
    end
  end
end

RSpec.describe "Orders", type: :request do
  let!(:alice) { User.create!(name: "Alice", email: "alice@user.com", password: "pass123") }
  let!(:bob)   { User.create!(name: "Bob",   email: "bob@user.com",   password: "pass123") }
  let!(:order_bob) do
    Order.create!(user: bob, total: 99.90, status: "pending",
                  address: "Rua Bob, 7", card_last4: "5678")
  end

  before do
    post login_path, params: { email: "alice@user.com", password: "pass123" }
  end

  describe "GET /orders/:id" do
    context "IDOR attempt" do
      it "não permite que Alice acesse o pedido de Bob" do
        get order_path(order_bob)
        expect(response).not_to have_http_status(:ok)
      end
    end
  end
end
