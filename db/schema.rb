# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171204060446) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bids", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["product_id"], name: "index_bids_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_bids_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "blacklists", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "to_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_blacklists_on_soft_destroyed_at"
    t.index ["to_user_id"], name: "index_blacklists_on_to_user_id"
    t.index ["user_id"], name: "index_blacklists_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
    t.index ["soft_destroyed_at"], name: "index_categories_on_soft_destroyed_at"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "to_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_follows_on_soft_destroyed_at"
    t.index ["to_user_id"], name: "index_follows_on_to_user_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "mylists", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["product_id"], name: "index_mylists_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_mylists_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_mylists_on_user_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.text "image", null: false
    t.integer "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.string "name"
    t.text "description"
    t.datetime "dulation_start"
    t.datetime "dulation_end"
    t.integer "type"
    t.integer "start_price"
    t.integer "prompt_dicision_price"
    t.datetime "ended_at"
    t.string "addr_1"
    t.string "addr_2"
    t.integer "shipping_user"
    t.integer "shipping_type"
    t.string "delivery"
    t.integer "shipping_cost"
    t.integer "shipping_okinawa"
    t.integer "shipping_hokkaido"
    t.integer "shipping_island"
    t.string "international_shipping"
    t.integer "delivery_date"
    t.integer "state"
    t.string "state_comment"
    t.boolean "returns"
    t.string "returns_comment"
    t.boolean "auto_extension"
    t.boolean "early_termination"
    t.integer "auto_resale"
    t.integer "resaled"
    t.integer "lower_price"
    t.boolean "special_featured"
    t.boolean "special_bold"
    t.boolean "special_bgcolor"
    t.integer "special_icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["soft_destroyed_at"], name: "index_products_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "account"
    t.string "name"
    t.string "zip"
    t.string "birthday"
    t.boolean "allow_mail"
    t.boolean "seller"
    t.string "company"
    t.string "contact_name"
    t.string "addr_1"
    t.string "addr_2"
    t.string "addr_3"
    t.string "tel"
    t.string "bank"
    t.string "bank_branch"
    t.integer "bank_account_type"
    t.string "bank_account_number"
    t.string "bank_account_hodler"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["soft_destroyed_at"], name: "index_users_on_soft_destroyed_at"
  end

end
