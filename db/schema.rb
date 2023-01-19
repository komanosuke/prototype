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

ActiveRecord::Schema.define(version: 2023_01_17_040455) do

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bench_audios", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "audio"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bench_audios_on_user_id"
  end

  create_table "bench_images", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bench_images_on_user_id"
  end

  create_table "bench_videos", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "video"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bench_videos_on_user_id"
  end

  create_table "benches", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.string "mac_address"
    t.string "os_name"
    t.date "introduced_date"
    t.string "position"
    t.boolean "timer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_benches_on_park_id"
  end

  create_table "cameras", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.string "mac_address"
    t.string "os_name"
    t.date "introduced_date"
    t.string "position"
    t.boolean "timer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_cameras_on_park_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "category", null: false
    t.string "name", null: false
    t.string "organization", null: false
    t.string "email", null: false
    t.string "tel", null: false
    t.text "message", null: false
    t.boolean "agree", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.text "contents"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_events_on_park_id"
  end

  create_table "parks", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "zip"
    t.string "prefecture"
    t.string "city"
    t.string "street"
    t.string "address"
    t.string "hours"
    t.string "tel"
    t.string "fee"
    t.string "map"
    t.string "website"
    t.string "iframe"
    t.string "size"
    t.text "profile"
    t.string "status"
    t.string "parking_info"
    t.string "toilet_info"
    t.string "playground_info"
    t.string "facility_info"
    t.string "sports_info"
    t.string "view_info"
    t.string "disaster_info"
    t.string "other_info"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_parks_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.string "picture"
    t.string "size"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_pictures_on_park_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.text "contents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_products_on_park_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shortcuts", force: :cascade do |t|
    t.integer "bench_id"
    t.string "name"
    t.text "program"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bench_id"], name: "index_shortcuts_on_bench_id"
  end

  create_table "tmp_data", force: :cascade do |t|
    t.string "data"
    t.string "mac_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tmp_messages", force: :cascade do |t|
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "zip"
    t.string "prefecture"
    t.string "city"
    t.string "street"
    t.string "address"
    t.string "tel"
    t.string "municipality"
    t.string "division"
    t.string "image"
    t.text "profile"
    t.string "notification"
    t.string "flag"
    t.text "admin_memo"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bench_audios", "users"
  add_foreign_key "bench_images", "users"
  add_foreign_key "bench_videos", "users"
  add_foreign_key "benches", "parks"
  add_foreign_key "cameras", "parks"
  add_foreign_key "events", "parks"
  add_foreign_key "parks", "users"
  add_foreign_key "pictures", "parks"
  add_foreign_key "products", "parks"
  add_foreign_key "shortcuts", "benches"
end
