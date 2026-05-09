# Dados para o BookStore Attack Lab (idempotente).
# Rode: bin/rails db:seed

admin = User.find_or_initialize_by(email: "admin@bookstore.com")
admin.assign_attributes(name: "Admin", password: "password123", role: "admin", credits: 0)
admin.save!

alice = User.find_or_initialize_by(email: "alice@user.com")
alice.assign_attributes(name: "Alice", password: "pass123", role: "user", credits: 10)
alice.save!

bob = User.find_or_initialize_by(email: "bob@user.com")
bob.assign_attributes(name: "Bob", password: "pass123", role: "user", credits: 5)
bob.save!

book = Book.find_or_initialize_by(title: "Ruby por exemplo")
book.assign_attributes(
  author: "Coautor Demo",
  description: "Livro de laboratório.",
  price: 49.90,
  category: "tech",
  stock: 3
)
book.save!

unless bob.orders.exists?
  order = Order.create!(
    user: bob,
    total: 99.90,
    status: "pending",
    address: "Rua Bob, 7 — São Paulo",
    card_last4: "5678"
  )
  OrderItem.create!(order: order, book: book, quantity: 1, price: book.price)
end
