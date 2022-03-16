# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_03_15_203424) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_number", null: false
    t.decimal "balance", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_accounts_on_account_number", unique: true
  end

  create_table "accounts_users", id: false, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_accounts_users_on_account_id"
    t.index ["user_id"], name: "index_accounts_users_on_user_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "sender_account_id", null: false
    t.bigint "receiver_account_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_account_id"], name: "index_transfers_on_receiver_account_id"
    t.index ["sender_account_id"], name: "index_transfers_on_sender_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "login", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "transfers", "accounts", column: "receiver_account_id"
  add_foreign_key "transfers", "accounts", column: "sender_account_id"
end
