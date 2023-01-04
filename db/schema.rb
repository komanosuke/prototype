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

ActiveRecord::Schema.define(version: 2022_12_27_093123) do

  create_table "bench_audios", force: :cascade do |t|
    t.integer "bench_id"
    t.string "name"
    t.string "audio"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bench_id"], name: "index_bench_audios_on_bench_id"
  end

  create_table "bench_images", force: :cascade do |t|
    t.integer "bench_id"
    t.string "name"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bench_id"], name: "index_bench_images_on_bench_id"
  end

  create_table "bench_videos", force: :cascade do |t|
    t.integer "bench_id"
    t.string "name"
    t.string "video"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bench_id"], name: "index_bench_videos_on_bench_id"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["park_id"], name: "index_events_on_park_id"
  end

  create_table "media", force: :cascade do |t|
    t.date "date"
    t.string "title"
    t.text "contents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "news", force: :cascade do |t|
    t.date "date"
    t.string "title"
    t.text "contents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "parks", force: :cascade do |t|
    t.integer "user_id"
    t.date "post_date"
    t.string "post_status"
    t.string "name"
    t.string "zip"
    t.string "prefecture"
    t.string "address"
    t.string "street"
    t.json "hours"
    t.string "tel"
    t.json "fee"
    t.string "map"
    t.string "website"
    t.string "size"
    t.text "profile"
    t.string "status"
    t.json "parking_info"
    t.json "toilet_info"
    t.json "playground_info"
    t.json "facility_info"
    t.json "sports_info"
    t.json "view_info"
    t.json "disaster_info"
    t.json "other_info"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_parks_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer "park_id"
    t.string "name"
    t.binary "picture"
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
    t.date "introduced_date"
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
    t.string "role"
    t.date "registered"
    t.integer "login"
    t.string "display_name"
    t.string "email"
    t.string "password_digest"
    t.string "zip"
    t.string "prefecture"
    t.string "address"
    t.string "street"
    t.string "tel"
    t.string "municipality"
    t.string "division"
    t.binary "image"
    t.text "profile"
    t.string "notification"
    t.string "flag"
    t.text "admin_memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bench_audios", "benches"
  add_foreign_key "bench_images", "benches"
  add_foreign_key "bench_videos", "benches"
  add_foreign_key "benches", "parks"
  add_foreign_key "events", "parks"
  add_foreign_key "parks", "users"
  add_foreign_key "pictures", "parks"
  add_foreign_key "products", "parks"
  add_foreign_key "shortcuts", "benches"
end
