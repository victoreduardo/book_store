ActiveRecord::Schema[7.1].define(version: 2024_01_01_000001) do
  create_table "users", force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "email",          null: false
    t.string   "password_digest"
    t.string   "role",           default: "user"
    t.integer  "credits",        default: 0
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index    ["email"],        name: "index_users_on_email", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string   "title",       null: false
    t.string   "author",      null: false
    t.text     "description"
    t.decimal  "price",       precision: 10, scale: 2
    t.string   "category"
    t.integer  "stock",       default: 0
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "book_id",    null: false
    t.integer  "user_id",    null: false
    t.text     "body",       null: false
    t.integer  "rating",     default: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.decimal  "total",      precision: 10, scale: 2
    t.string   "status",     default: "pending"
    t.string   "address"
    t.string   "card_last4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",   null: false
    t.integer  "book_id",    null: false
    t.integer  "quantity",   default: 1
    t.decimal  "price",      precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
