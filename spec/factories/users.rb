# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name     { Faker::Name.full_name }
    email    { Faker::Internet.unique.email }
    password { "password123" }
    role     { "user" }
    credits  { 0 }

    trait :admin do
      role    { "admin" }
      credits { 5000 }
    end
  end

  factory :book do
    title       { Faker::Book.title }
    author      { Faker::Book.author }
    description { Faker::Lorem.paragraph }
    price       { Faker::Commerce.price(range: 10.0..200.0) }
    category    { %w[Programação Segurança Rails Arquitetura].sample }
    stock       { Faker::Number.between(from: 0, to: 50) }
  end

  factory :comment do
    association :book
    association :user
    body   { Faker::Lorem.sentence }
    rating { Faker::Number.between(from: 1, to: 5) }
  end

  factory :order do
    association :user
    total      { Faker::Commerce.price(range: 50.0..500.0) }
    status     { "pending" }
    address    { Faker::Address.full_address }
    card_last4 { Faker::Number.number(digits: 4).to_s }
  end
end
