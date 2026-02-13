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

ActiveRecord::Schema[7.2].define(version: 2026_02_13_032116) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "yt_username", null: false
    t.string "yt_profile_picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "pair_votes", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "title_thumbnail_pair_id", null: false
    t.string "voter_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title_thumbnail_pair_id"], name: "index_pair_votes_on_title_thumbnail_pair_id"
    t.index ["variant_id", "voter_name"], name: "index_pair_votes_on_variant_id_and_voter_name", unique: true
    t.index ["variant_id"], name: "index_pair_votes_on_variant_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_user_id", null: false
    t.index ["admin_user_id", "name"], name: "index_recipients_on_admin_user_id_and_name", unique: true
    t.index ["admin_user_id"], name: "index_recipients_on_admin_user_id"
  end

  create_table "title_thumbnail_pairs", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.string "title", null: false
    t.string "thumbnail_url"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variant_id"], name: "index_title_thumbnail_pairs_on_variant_id"
  end

  create_table "variant_votes", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.bigint "variant_id", null: false
    t.string "voter_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variant_id"], name: "index_variant_votes_on_variant_id"
    t.index ["video_id", "voter_name"], name: "index_variant_votes_on_video_id_and_voter_name", unique: true
    t.index ["video_id"], name: "index_variant_votes_on_video_id"
  end

  create_table "variants", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["video_id"], name: "index_variants_on_video_id"
  end

  create_table "video_shares", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.bigint "recipient_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_video_shares_on_recipient_id"
    t.index ["token"], name: "index_video_shares_on_token", unique: true
    t.index ["video_id", "recipient_id"], name: "index_video_shares_on_video_id_and_recipient_id", unique: true
    t.index ["video_id"], name: "index_video_shares_on_video_id"
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.string "working_title", null: false
    t.string "sample_views", default: "1.2K views"
    t.string "share_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video_duration", default: "10:30"
    t.index ["admin_user_id"], name: "index_videos_on_admin_user_id"
    t.index ["share_token"], name: "index_videos_on_share_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pair_votes", "title_thumbnail_pairs"
  add_foreign_key "pair_votes", "variants"
  add_foreign_key "recipients", "admin_users"
  add_foreign_key "title_thumbnail_pairs", "variants"
  add_foreign_key "variant_votes", "variants"
  add_foreign_key "variant_votes", "videos"
  add_foreign_key "variants", "videos"
  add_foreign_key "video_shares", "recipients"
  add_foreign_key "video_shares", "videos"
  add_foreign_key "videos", "admin_users"
end
