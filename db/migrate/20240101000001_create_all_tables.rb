class CreateAllTables < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string  :name,     null: false
      t.string  :email,    null: false
      t.string  :password_digest
      t.string  :role,     default: "user"
      t.integer :credits,  default: 0
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :books do |t|
      t.string  :title,    null: false
      t.string  :author,   null: false
      t.text    :description
      t.decimal :price,    precision: 10, scale: 2
      t.string  :category
      t.integer :stock,    default: 0
      t.timestamps
    end

    create_table :comments do |t|
      t.references :book,  null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.text    :body,     null: false
      t.integer :rating,   default: 5
      t.timestamps
    end

    create_table :orders do |t|
      t.references :user,  null: false, foreign_key: true
      t.decimal :total,    precision: 10, scale: 2
      t.string  :status,   default: "pending"
      t.string  :address
      t.string  :card_last4
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :book,  null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :price,    precision: 10, scale: 2
      t.timestamps
    end
  end
end
