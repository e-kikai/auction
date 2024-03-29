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

ActiveRecord::Schema.define(version: 2022_04_21_074833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ab_checkpoints", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.bigint "abtest_id"
    t.index ["abtest_id"], name: "index_ab_checkpoints_on_abtest_id"
    t.index ["product_id"], name: "index_ab_checkpoints_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_ab_checkpoints_on_soft_destroyed_at"
  end

  create_table "abtests", force: :cascade do |t|
    t.string "utag", default: "", null: false
    t.string "label", null: false
    t.string "segment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.datetime "finished_at"
    t.index ["soft_destroyed_at"], name: "index_abtests_on_soft_destroyed_at"
    t.index ["utag", "label"], name: "index_abtests_on_utag_and_label", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.bigint "product_image_id"
    t.text "keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.integer "company_id"
    t.string "name", default: ""
    t.index ["category_id"], name: "index_alerts_on_category_id"
    t.index ["product_image_id"], name: "index_alerts_on_product_image_id"
    t.index ["soft_destroyed_at"], name: "index_alerts_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["product_id"], name: "index_bids_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_bids_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "blacklists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "to_user_id", null: false
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
    t.integer "order_no", default: 999999999, null: false
    t.string "search_order_no", default: "", null: false
    t.index ["ancestry"], name: "index_categories_on_ancestry"
    t.index ["soft_destroyed_at"], name: "index_categories_on_soft_destroyed_at"
  end

  create_table "company_chats", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "res_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["res_id"], name: "index_company_chats_on_res_id"
    t.index ["soft_destroyed_at"], name: "index_company_chats_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_company_chats_on_user_id"
  end

  create_table "detail_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.string "ip"
    t.string "host"
    t.string "ua"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "referer"
    t.string "r", default: "", null: false
    t.string "utag"
    t.boolean "nonlogin", default: true
    t.index ["product_id"], name: "index_detail_logs_on_product_id"
    t.index ["user_id"], name: "index_detail_logs_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "to_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_follows_on_soft_destroyed_at"
    t.index ["to_user_id"], name: "index_follows_on_to_user_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "helps", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "content", default: "", null: false
    t.integer "target", default: 0, null: false
    t.integer "order_no", default: 999999999, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "uid", default: "", null: false
    t.index ["soft_destroyed_at"], name: "index_helps_on_soft_destroyed_at"
    t.index ["uid"], name: "index_helps_on_uid", unique: true
  end

  create_table "importlogs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.integer "status"
    t.string "code"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["product_id"], name: "index_importlogs_on_product_id"
    t.index ["user_id"], name: "index_importlogs_on_user_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "order_no", default: 9999999, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["soft_destroyed_at"], name: "index_industries_on_soft_destroyed_at"
  end

  create_table "industry_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "industry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_industry_users_on_industry_id"
    t.index ["user_id"], name: "index_industry_users_on_user_id"
  end

  create_table "infos", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "content", default: "", null: false
    t.integer "target", default: 0, null: false
    t.datetime "start_at", default: -> { "now()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "uid", default: "", null: false
    t.index ["soft_destroyed_at"], name: "index_infos_on_soft_destroyed_at"
    t.index ["uid"], name: "index_infos_on_uid", unique: true
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.text "image", null: false
    t.integer "order_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_nitamonos", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "nitamono_id", null: false
    t.float "norm", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["nitamono_id"], name: "index_product_nitamonos_on_nitamono_id"
    t.index ["product_id", "nitamono_id"], name: "index_product_nitamonos_on_product_id_and_nitamono_id", unique: true
    t.index ["product_id"], name: "index_product_nitamonos_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_product_nitamonos_on_soft_destroyed_at"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "name", limit: 255, default: "", null: false, collation: "ja_JP.utf8"
    t.text "description"
    t.datetime "dulation_start"
    t.datetime "dulation_end"
    t.integer "sell_type", default: 0, null: false
    t.integer "start_price"
    t.integer "prompt_dicision_price"
    t.datetime "ended_at"
    t.string "addr_1"
    t.string "addr_2"
    t.integer "shipping_user", default: 0, null: false
    t.integer "shipping_type"
    t.string "shipping_comment"
    t.integer "delivery_date", default: 0, null: false
    t.integer "state", default: 0, null: false
    t.string "state_comment"
    t.boolean "returns", default: false, null: false
    t.string "returns_comment"
    t.boolean "auto_extension", default: true, null: false
    t.boolean "early_termination", default: false, null: false
    t.integer "auto_resale", default: 8
    t.integer "resaled"
    t.integer "lower_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.integer "max_price", default: 0
    t.integer "bids_count", default: 0
    t.integer "max_bid_id"
    t.integer "fee"
    t.string "code"
    t.boolean "template", default: false, null: false
    t.integer "machinelife_id"
    t.text "machinelife_images"
    t.integer "shipping_no"
    t.text "cancel"
    t.text "hashtags", default: "", null: false
    t.integer "star"
    t.text "note"
    t.integer "watches_count", default: 0, null: false
    t.integer "detail_logs_count", default: 0, null: false
    t.text "additional", default: "", null: false
    t.text "packing", default: "", null: false
    t.string "youtube", default: "", null: false
    t.boolean "international", default: false, null: false
    t.text "search_keywords", default: "", null: false
    t.integer "auto_resale_date", default: 7, null: false
    t.integer "stock"
    t.integer "dst_id"
    t.string "maker", default: "", null: false
    t.string "model", default: "", null: false
    t.string "year", default: "", null: false
    t.boolean "commision", default: false
    t.string "accesory", default: ""
    t.datetime "suspend"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["soft_destroyed_at"], name: "index_products_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "detail", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "ip"
    t.string "host"
    t.string "utag"
    t.string "ua"
    t.boolean "display", default: false
    t.index ["soft_destroyed_at"], name: "index_requests_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "result_logs", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "bid_id_id"
    t.datetime "result_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.index ["bid_id_id"], name: "index_result_logs_on_bid_id_id"
    t.index ["product_id"], name: "index_result_logs_on_product_id"
    t.index ["result_at"], name: "index_result_logs_on_result_at"
    t.index ["soft_destroyed_at"], name: "index_result_logs_on_soft_destroyed_at"
  end

  create_table "search_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.integer "company_id"
    t.string "keywords"
    t.bigint "search_id"
    t.string "ip"
    t.string "host"
    t.string "referer"
    t.string "ua"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "r", default: "", null: false
    t.bigint "nitamono_product_id"
    t.string "path", default: "", null: false
    t.integer "page", default: 1, null: false
    t.string "utag"
    t.boolean "nonlogin", default: true
    t.index ["category_id"], name: "index_search_logs_on_category_id"
    t.index ["search_id"], name: "index_search_logs_on_search_id"
    t.index ["user_id"], name: "index_search_logs_on_user_id"
  end

  create_table "searches", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.bigint "product_image_id"
    t.string "name"
    t.text "keywords"
    t.text "q"
    t.boolean "publish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.integer "company_id"
    t.text "description", default: ""
    t.index ["category_id"], name: "index_searches_on_category_id"
    t.index ["product_image_id"], name: "index_searches_on_product_image_id"
    t.index ["soft_destroyed_at"], name: "index_searches_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shipping_fees", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "shipping_no"
    t.string "addr_1"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shipping_fees_on_user_id"
  end

  create_table "shipping_labels", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "shipping_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "#<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition"
    t.index ["user_id"], name: "index_shipping_labels_on_user_id"
  end

  create_table "toppage_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "ip"
    t.string "host"
    t.string "referer"
    t.string "ua"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "r", default: "", null: false
    t.string "utag"
    t.boolean "nonlogin", default: true
    t.index ["user_id"], name: "index_toppage_logs_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.bigint "owner_id"
    t.index ["owner_id"], name: "index_trades_on_owner_id"
    t.index ["product_id"], name: "index_trades_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_trades_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "account"
    t.string "name"
    t.string "zip"
    t.string "birthday"
    t.boolean "allow_mail", default: true, null: false
    t.boolean "seller", default: false, null: false
    t.string "company"
    t.string "contact_name"
    t.string "addr_1"
    t.string "addr_2"
    t.string "addr_3"
    t.string "tel"
    t.text "bank"
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
    t.string "charge"
    t.string "fax"
    t.string "url"
    t.string "license"
    t.string "business_hours"
    t.text "note"
    t.text "result_message", default: "", null: false
    t.text "header_image"
    t.integer "machinelife_company_id"
    t.boolean "special", default: false
    t.index ["email", "soft_destroyed_at"], name: "index_users_on_email_and_soft_destroyed_at", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["soft_destroyed_at"], name: "index_users_on_soft_destroyed_at"
  end

  create_table "watches", force: :cascade do |t|
    t.integer "user_id"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "soft_destroyed_at"
    t.string "r"
    t.string "referer"
    t.string "ip"
    t.string "host"
    t.string "ua"
    t.string "utag"
    t.boolean "nonlogin", default: false
    t.index ["product_id"], name: "index_watches_on_product_id"
    t.index ["soft_destroyed_at"], name: "index_watches_on_soft_destroyed_at"
    t.index ["user_id"], name: "index_watches_on_user_id"
  end

  add_foreign_key "ab_checkpoints", "abtests"
  add_foreign_key "ab_checkpoints", "products"
  add_foreign_key "company_chats", "company_chats", column: "res_id"
  add_foreign_key "industry_users", "industries"
  add_foreign_key "industry_users", "users"
  add_foreign_key "product_nitamonos", "products"
  add_foreign_key "requests", "users"
  add_foreign_key "trades", "users", column: "owner_id"
end
