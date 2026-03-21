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

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", comment: "商品", force: :cascade do |t|
    t.string "name", comment: "商品名"
    t.string "comment", comment: "コメント"
    t.date "usage_start_date", comment: "使用開始日"
    t.date "usage_end_date", comment: "使用終了日"
    t.bigint "create_user_id", comment: "作成者id"
    t.bigint "update_user_id", comment: "更新者id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_item_id"
    t.index ["create_user_id"], name: "index_items_on_create_user_id"
    t.index ["parent_item_id"], name: "index_items_on_parent_item_id"
    t.index ["update_user_id"], name: "index_items_on_update_user_id"
  end

  create_table "notices", comment: "お知らせ", force: :cascade do |t|
    t.string "title", comment: "タイトル"
    t.text "body", comment: "本文"
    t.datetime "publish_start_datetime", precision: nil, comment: "公開開始日時"
    t.datetime "publish_end_datetime", precision: nil, comment: "公開終了日時"
    t.bigint "create_user_id", comment: "作成者id"
    t.bigint "update_user_id", comment: "更新者id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["create_user_id"], name: "index_notices_on_create_user_id"
    t.index ["update_user_id"], name: "index_notices_on_update_user_id"
  end

  create_table "rparam_memories", force: :cascade do |t|
    t.string "user_type"
    t.bigint "user_id"
    t.string "action"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_type", "user_id"], name: "index_rparam_memories_on_user_type_and_user_id"
  end

  create_table "users", comment: "ユーザ", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "username", comment: "ユーザ名"
    t.string "name", comment: "氏名"
    t.string "search_name", comment: "検索用氏名"
    t.string "furigana", comment: "ふりがな"
    t.string "search_furigana", comment: "検索用ふりがな"
    t.datetime "password_change_datetime", precision: nil, comment: "パスワード変更日時"
    t.boolean "admin", default: false, null: false, comment: "管理者"
    t.string "jti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "items", "items", column: "parent_item_id"
end
